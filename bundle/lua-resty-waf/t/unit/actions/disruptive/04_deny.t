use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
	lua_package_path "$pwd/lib/?.lua;;";
	lua_package_cpath "$pwd/lib/?.lua;;";
};

repeat_each(3);
plan tests => repeat_each() * 4 * blocks();

no_shuffle();
run_tests();

__DATA__

=== TEST 1: DENY exits the phase with waf._deny_status
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local actions = require "resty.waf.actions"

			actions.disruptive_lookup["DENY"]({ _debug = true, _debug_log_level = ngx.INFO, _mode = "ACTIVE", _deny_status = 403 }, {})

			ngx.log(ngx.INFO, "We should not see this")
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 403
--- error_log
Rule action was DENY, so telling nginx to quit
--- no_error_log
[error]
We should not see this

=== TEST 2: DENY does not exit the phase when mode is not ACTIVE
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local actions = require "resty.waf.actions"

			actions.disruptive_lookup["DENY"]({ _debug = true, _debug_log_level = ngx.INFO, _mode = "SIMULATE", _deny_status = 403 }, {})

			ngx.log(ngx.INFO, "We should see this")
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 200
--- error_log
Rule action was DENY, so telling nginx to quit
We should see this
--- no_error_log
[error]
