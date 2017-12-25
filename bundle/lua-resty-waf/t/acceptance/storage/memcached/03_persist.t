use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
	lua_package_path "$pwd/lib/?.lua;;";
	lua_package_cpath "$pwd/lib/?.lua;;";
};

repeat_each(3);
plan tests => repeat_each() * 5 * blocks() + 3;

no_shuffle();
run_tests();

__DATA__

=== TEST 1: Persist a collection
--- http_config eval
$::HttpConfig . q#
	init_by_lua_block {
		local lua_resty_waf = require "resty.waf"
	}
#
--- config
    location = /t {
        access_by_lua_block {
			local memcached_m   = require "resty.memcached"
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:set_option("storage_backend", "memcached")
			waf:set_option("debug", true)

			local ctx = { storage = {}, col_lookup = { FOO = "FOO" } }
			local var = require("cjson").encode({ COUNT = 5 })

			local storage = require "resty.waf.storage"
			storage.col_prefix = ngx.worker.pid()

			local memcached = memcached_m:new()
			memcached:connect(waf._storage_memcached_host, waf._storage_memcached_port)
			memcached:set(storage.col_prefix .. "FOO", var)

			storage.initialize(waf, ctx.storage, "FOO")

			local element = { col = "FOO", key = "COUNT", value = 1 }
			storage.set_var(waf, ctx, element, element.value)

			storage.persist(waf, ctx.storage)
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 200
--- error_log
Persisting storage type memcached
Examining FOO
Persisting value: {"COUNT":1}
--- no_error_log
[error]
Not persisting a collection that wasn't altered

=== TEST 2: Don't persist an unaltered collection
--- http_config eval
$::HttpConfig . q#
	init_by_lua_block {
		local lua_resty_waf = require "resty.waf"
	}
#
--- config
    location = /t {
        access_by_lua_block {
			local memcached_m   = require "resty.memcached"
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:set_option("storage_backend", "memcached")
			waf:set_option("debug", true)

			local ctx = { storage = {}, col_lookup = { FOO = "FOO" } }
			local var = require("cjson").encode({ COUNT = 5 })

			local storage = require "resty.waf.storage"
			storage.col_prefix = ngx.worker.pid()

			local memcached = memcached_m:new()
			memcached:connect(waf._storage_memcached_host, waf._storage_memcached_port)
			memcached:set(storage.col_prefix .. "FOO", var)

			storage.initialize(waf, ctx.storage, "FOO")

			storage.persist(waf, ctx.storage)
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 200
--- error_log
Examining FOO
Not persisting a collection that wasn't altered
--- no_error_log
[error]
Persisting value: {"

=== TEST 3: Persist an unaltered collection with expired keys
--- http_config eval
$::HttpConfig . q#
	init_by_lua_block {
		local lua_resty_waf = require "resty.waf"
	}
#
--- config
    location = /t {
        access_by_lua_block {
			local memcached_m   = require "resty.memcached"
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:set_option("storage_backend", "memcached")
			waf:set_option("debug", true)

			local ctx = { storage = {}, col_lookup = { FOO = "FOO" } }
			local var = require("cjson").encode({ COUNT = 5, __expire_COUNT = ngx.time() - 10, BAR = 1 })

			local storage = require "resty.waf.storage"
			storage.col_prefix = ngx.worker.pid()

			local memcached = memcached_m:new()
			memcached:connect(waf._storage_memcached_host, waf._storage_memcached_port)
			memcached:set(storage.col_prefix .. "FOO", var)

			storage.initialize(waf, ctx.storage, "FOO")

			storage.persist(waf, ctx.storage)
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 200
--- error_log
Examining FOO
Persisting value: {"BAR":1}
--- no_error_log
[error]
Not persisting a collection that wasn't altered

=== TEST 4: Don't persist the TX collection
--- http_config eval
$::HttpConfig . q#
	init_by_lua_block {
		local lua_resty_waf = require "resty.waf"
	}
#
--- config
    location = /t {
        access_by_lua_block {
			local memcached_m   = require "resty.memcached"
			local lua_resty_waf = require "resty.waf"
			local waf           = lua_resty_waf:new()

			waf:set_option("storage_backend", "memcached")
			waf:set_option("debug", true)

			local ctx = { storage = { TX = {} }, col_lookup = { TX = "TX" } }
			local var = require("cjson").encode({ COUNT = 5 })

			local storage = require "resty.waf.storage"

			local element = { col = "TX", key = "COUNT", value = 1 }
			storage.set_var(waf, ctx, element, element.value)

			storage.persist(waf, ctx.storage)
		}

		content_by_lua_block {ngx.exit(ngx.HTTP_OK)}
	}
--- request
GET /t
--- error_code: 200
--- no_error_log
[error]
Examining TX
Not persisting a collection that wasn't altered
Persisting value: {"

