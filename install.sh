#!/bin/bash

yum groupinstall 'Development Tools' -y
yum install lua-devel readline-devel pcre-devel gcc perl-Digest-* zlib-devel -y

SECONDS=0

gmake clean

cd ./openssl-fips
./config
make clean

cd ./openssl-fips-2.0.16
./config fips no-ec2m no-ssl2 no-ssl3 no-weak-ssl-ciphers -O3 -Ofast -march=native
make clean
make -j$(grep -c ^processor /proc/cpuinfo)
make install

./config
make clean
cd ../../

./configure \
--with-cc-opt='-O3 -Ofast -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=native -DTCP_FASTOPEN=23' \
--with-pcre-jit \
--with-stream \
--with-stream_ssl_module \
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
--with-openssl=openssl-fips \
--with-openssl-opt='fips no-ec2m no-ssl2 no-ssl3 no-weak-ssl-ciphers -O3 -Ofast -w -m64 -mtune=native' \
-j$(grep -c ^processor /proc/cpuinfo)

gmake j$(grep -c ^processor /proc/cpuinfo)
gmake install
rm -f /usr/lib/systemd/system/openresty.service
cp ./util/openresty.service /usr/lib/systemd/system/ -v
rm -f /usr/local/bin/openresty
ln -s /usr/local/openresty/bin/openresty /usr/local/bin/openresty
systemctl daemon-reload
systemctl enable openresty

mkdir -p /var/log/nginx
chown nobody:nobody /var/log/nginx

if (( $SECONDS > 3600 )) ; then
    let "hours=SECONDS/3600"
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)" 
elif (( $SECONDS > 60 )) ; then
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $minutes minute(s) and $seconds second(s)"
else
    echo "Completed in $SECONDS seconds"
fi
