use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
	lua_package_path "$pwd/lib/?.lua;;";
	lua_package_cpath "$pwd/lib/?.lua;;";
};

repeat_each(3);
plan tests => repeat_each() * 3 * blocks() ;

no_shuffle();
run_tests();

__DATA__

=== TEST 1: REQUEST_LINE collections variable (simple)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(collections.REQUEST_LINE)
		}
	}
--- request
GET /t
--- error_code: 200
--- response_body
GET /t HTTP/1.1
--- no_error_log
[error]

=== TEST 2: REQUEST_LINE collections variable (single pair)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(collections.REQUEST_LINE)
		}
	}
--- request
GET /t?foo=bar
--- error_code: 200
--- response_body
GET /t?foo=bar HTTP/1.1
--- no_error_log
[error]

=== TEST 3: REQUEST_LINE collections variable (complex)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(collections.REQUEST_LINE)
		}
	}
--- request
GET /t?foo=bar&foo=bat&frob&qux=
--- error_code: 200
--- response_body
GET /t?foo=bar&foo=bat&frob&qux= HTTP/1.1
--- no_error_log
[error]

=== TEST 4: REQUEST_LINE collections variable (type verification)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.say(type(collections.REQUEST_LINE))
		}
	}
--- request
GET /t
--- error_code: 200
--- response_body
string
--- no_error_log
[error]

