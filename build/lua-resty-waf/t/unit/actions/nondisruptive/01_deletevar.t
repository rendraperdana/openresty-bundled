use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
	lua_package_path "$pwd/lib/?.lua;;";
	lua_package_cpath "$pwd/lib/?.lua;;";
};

repeat_each(3);
plan tests => repeat_each() * 3 * blocks();

no_shuffle();
run_tests();

__DATA__

=== TEST 1: deletevar calls storage.delete_var
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local actions = require "resty.waf.actions"
			local storage = require "resty.waf.storage"

			storage.delete_var = function(waf, ctx, data)
				ngx.log(ngx.DEBUG, "Called storage.delete_var with data.value " .. data.value)
			end

			actions.nondisruptive_lookup["deletevar"]({}, { value = "foo" }, {}, {})
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 200
--- error_log
Called storage.delete_var with data.value foo
--- no_error_log
[error]

