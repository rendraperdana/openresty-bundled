.PHONY: all install clean

all:
	cd /opt/openresty-bundled/build/LuaJIT-2.1-20170808 && $(MAKE) TARGET_STRIP=@: CCDEBUG=-g XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT -msse4.2' CC=cc PREFIX=/usr/local/openresty/luajit
	cd /opt/openresty-bundled/build/lua-cjson-2.1.0.5 && $(MAKE) DESTDIR=$(DESTDIR) LUA_INCLUDE_DIR=/opt/openresty-bundled/build/luajit-root/usr/local/openresty/luajit/include/luajit-2.1 LUA_CMODULE_DIR=/usr/local/openresty/lualib LUA_MODULE_DIR=/usr/local/openresty/lualib CJSON_CFLAGS="-g -fpic" CC=cc
	cd /opt/openresty-bundled/build/lua-redis-parser-0.13 && $(MAKE) DESTDIR=$(DESTDIR) LUA_INCLUDE_DIR=/opt/openresty-bundled/build/luajit-root/usr/local/openresty/luajit/include/luajit-2.1 LUA_LIB_DIR=/usr/local/openresty/lualib CC=cc
	cd /opt/openresty-bundled/build/lua-rds-parser-0.06 && $(MAKE) DESTDIR=$(DESTDIR) LUA_INCLUDE_DIR=/opt/openresty-bundled/build/luajit-root/usr/local/openresty/luajit/include/luajit-2.1 LUA_LIB_DIR=/usr/local/openresty/lualib CC=cc
	cd /opt/openresty-bundled/build/nginx-1.11.2 && $(MAKE)

install: all
	mkdir -p $(DESTDIR)/usr/local/openresty/
	-cp /opt/openresty-bundled/COPYRIGHT $(DESTDIR)/usr/local/openresty/
	cd /opt/openresty-bundled/build/LuaJIT-2.1-20170808 && $(MAKE) install TARGET_STRIP=@: CCDEBUG=-g XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT -msse4.2' CC=cc PREFIX=/usr/local/openresty/luajit DESTDIR=$(DESTDIR)
	cd /opt/openresty-bundled/build/lua-cjson-2.1.0.5 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_INCLUDE_DIR=/opt/openresty-bundled/build/luajit-root/usr/local/openresty/luajit/include/luajit-2.1 LUA_CMODULE_DIR=/usr/local/openresty/lualib LUA_MODULE_DIR=/usr/local/openresty/lualib CJSON_CFLAGS="-g -fpic" CC=cc
	cd /opt/openresty-bundled/build/lua-redis-parser-0.13 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_INCLUDE_DIR=/opt/openresty-bundled/build/luajit-root/usr/local/openresty/luajit/include/luajit-2.1 LUA_LIB_DIR=/usr/local/openresty/lualib CC=cc
	cd /opt/openresty-bundled/build/lua-rds-parser-0.06 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_INCLUDE_DIR=/opt/openresty-bundled/build/luajit-root/usr/local/openresty/luajit/include/luajit-2.1 LUA_LIB_DIR=/usr/local/openresty/lualib CC=cc
	cd /opt/openresty-bundled/build/lua-resty-dns-0.19 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-memcached-0.14 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-redis-0.26 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-mysql-0.20 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-string-0.10 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-upload-0.10 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-websocket-0.06 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-lock-0.07 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-lrucache-0.07 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-core-0.1.12 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-upstream-healthcheck-0.05 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/lua-resty-limit-traffic-0.04 && $(MAKE) install DESTDIR=$(DESTDIR) LUA_LIB_DIR=/usr/local/openresty/lualib INSTALL=/opt/openresty-bundled/build/install
	cd /opt/openresty-bundled/build/opm-0.0.3 && /opt/openresty-bundled/build/install bin/* $(DESTDIR)/usr/local/openresty/bin/
	cd /opt/openresty-bundled/build/resty-cli-0.19 && /opt/openresty-bundled/build/install bin/* $(DESTDIR)/usr/local/openresty/bin/
	cp /opt/openresty-bundled/build/resty.index $(DESTDIR)/usr/local/openresty/
	cp -r /opt/openresty-bundled/build/pod $(DESTDIR)/usr/local/openresty/
	cd /opt/openresty-bundled/build/nginx-1.11.2 && $(MAKE) install DESTDIR=$(DESTDIR)
	mkdir -p $(DESTDIR)/usr/local/openresty/site/lualib $(DESTDIR)/usr/local/openresty/site/pod $(DESTDIR)/usr/local/openresty/site/manifest
	ln -sf /usr/local/openresty/nginx/sbin/nginx $(DESTDIR)/usr/local/openresty/bin/openresty

clean:
	rm -rf build
