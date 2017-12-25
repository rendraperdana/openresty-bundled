FROM	centos:centos7
RUN	yum install epel-release yum-utils -y && yum makecache fast
RUN	yum install git bc gcc gcc-c++ automake autoconf make gmake lua-devel readline-devel pcre-devel perl-Digest-* wget curl zlib-devel zlib unzip tar -y && mkdir /opt/openresty-waf
COPY	. /opt/openresty-waf
RUN	cd /opt/openresty-waf && ./configure \
--with-cc-opt=' -O2 -Ofast -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=native -DTCP_FASTOPEN=23' \
--with-pcre-jit \
--with-ipv6 \
--with-stream \
--with-stream_ssl_module \
--with-http_v2_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--with-http_stub_status_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_secure_link_module \
--with-http_random_index_module \
--with-http_gzip_static_module \
--with-http_sub_module \
--with-http_gunzip_module \
--with-threads \
--with-file-aio \
--with-http_ssl_module \
--with-openssl=/opt/openresty-waf/openssl-1.0.2l -j$(grep -c ^processor /proc/cpuinfo)
RUN	cd /opt/openresty-waf && gmake -j$(grep -c ^processor /proc/cpuinfo) && gmake install
ENV 	PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/
#Integrate WAF
#=============
RUN	cd /opt/openresty-waf/bundle/luarocks-2.4.2 && make build -j$(grep -c ^processor /proc/cpuinfo) && make install
RUN	cd /opt/openresty-waf/bundle/LuaJIT-2.1-20170405 && make -j$(grep -c ^processor /proc/cpuinfo) && make install
RUN     cd /opt/openresty-waf/bundle/lua-resty-waf && make -j$(grep -c ^processor /proc/cpuinfo) && make install
#Copy WAF Rules
#==============
COPY	waf-rules /usr/local/openresty/site/lualib/rules/
EXPOSE	80 443
ENTRYPOINT ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
