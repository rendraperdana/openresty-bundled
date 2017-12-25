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

=== TEST 1: REMOTE_ADDR collections variable
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

			ngx.say(collections.REMOTE_ADDR)
		}
	}
--- request
GET /t
--- error_code: 200
--- response_body
127.0.0.1
--- no_error_log
[error]

=== TEST 2: REMOTE_ADDR collections variable (type verification)
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

			ngx.say(type(collections.REMOTE_ADDR))
		}
	}
--- request
GET /t
--- error_code: 200
--- response_body
string
--- no_error_log
[error]

