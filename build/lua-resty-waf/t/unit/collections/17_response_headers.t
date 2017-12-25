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

=== TEST 1: RESPONSE_HEADERS collections variable (single element)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			ngx.header["X-Foo"] = "bar"
			ngx.exit(ngx.HTTP_OK)
		}

		header_filter_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		log_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.log(ngx.INFO, [["]] .. collections.RESPONSE_HEADERS["X-Foo"] .. [["]])
		}
	}
--- request
GET /t
--- error_code: 200
--- error_log
"bar" while logging request
--- no_error_log
[error]

=== TEST 2: RESPONSE_HEADERS collections variable (multiple elements)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			ngx.header["X-Foo"] = { "bar", "baz" }
			ngx.exit(ngx.HTTP_OK)
		}

		header_filter_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		log_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			for k, v in ipairs(collections.RESPONSE_HEADERS["X-Foo"]) do
				ngx.log(ngx.INFO, [["]] .. v .. [["]])
			end
		}
	}
--- request
GET /t
--- error_code: 200
--- error_log
"bar" while logging request
"baz" while logging request
--- no_error_log
[error]

=== TEST 3: RESPONSE_HEADERS collections variable (non-existent element)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			ngx.exit(ngx.HTTP_OK)
		}

		header_filter_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		log_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.log(ngx.INFO, [["]] .. tostring(collections.RESPONSE_HEADERS["X-Foo"]) .. [["]])
		}
	}
--- request
GET /t
--- error_code: 200
--- error_log
"nil" while logging request
--- no_error_log
[error]

=== TEST 4: RESPONSE_HEADERS collections variable (type verification)
--- http_config eval: $::HttpConfig
--- config
	location /t {
		access_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		content_by_lua_block {
			ngx.exit(ngx.HTTP_OK)
		}

		header_filter_by_lua_block {
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:exec()
		}

		log_by_lua_block {
			local collections = ngx.ctx.lua_resty_waf.collections

			ngx.log(ngx.INFO, [["]] .. type(collections.RESPONSE_HEADERS) .. [["]])
		}
	}
--- request
GET /t
--- error_code: 200
--- error_log
"table" while logging request
--- no_error_log
[error]
