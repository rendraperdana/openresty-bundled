use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
	lua_package_path "$pwd/lib/?.lua;;";
	lua_package_cpath "$pwd/lib/?.lua;;";
};

repeat_each(3);
plan tests => repeat_each() * 3 * blocks() + 3;

no_shuffle();
run_tests();

__DATA__

=== TEST 1: Do not allow unknown content types
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:set_option("debug", true)
			waf:exec()
        }

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
    }
--- request
GET /t
--- more_headers
Content-Type: application/foobar
--- error_code: 403
--- error_log
application/foobar not a valid content type
--- no_error_log
[error]

=== TEST 2: Explicitly allow unknown content types
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:set_option("debug", true)
			waf:set_option("allow_unknown_content_types", true)
			waf:exec()
        }

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
    }
--- request
GET /t
--- more_headers
Content-Type: application/foobar
--- error_code: 200
--- error_log
Allowing request with content type application/foobar
--- no_error_log
[error]
application/foobar not a valid content type

