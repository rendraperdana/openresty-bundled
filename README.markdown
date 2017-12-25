Version
=======

Openresty       version 1.11.2.5

OpenSSL         version 1.0.2n-fips

...and many other components in official openresty official package

Known Issues
============

1. This package is excluding feature rds-csv-nginx-module due to compile failure
Will not effecting operation unless you explicitly need this directive:

rds_csv on;

rds_csv_row_terminator;


2. HTTP/2 is not supported due to limitation in lua-resty-upload. Enabling HTTP/2 will result in exception within lua when uploading (POST) contents that encodes with multipart/form or data.


INTRO
=====

This is openresty bundled with several LUA component served as Load Balancer and Web Application Firewall (WAF)

Tested on Centos 7 kernel 4.9.71

Main package:

Openresty:

https://github.com/openresty/openresty.org/


lua-resty-waf:

https://github.com/p0pr0ck5/lua-resty-waf

Prequisite
==========

yum groupinstall 'Development Tools'

yum install lua-devel readline-devel pcre-devel gcc perl-Digest-* zlib-devel -y

Also install openssl-devel if you prefer to use distros default openssl package:

yum install openssl-devel

remove --with-openssl on configuration below.

Compile & Install
=================

Common pitfall: please reconfig OpenSSL (note below) and execute make clean if below procedure failed.

You can configure compilation with flags:

./configure \
--with-cc-opt=' -O2 -Ofast -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=native -DTCP_FASTOPEN=23' \
--with-pcre-jit \
--with-ipv6 \
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
--with-openssl=openssl-1.0.2n \
-j$(grep -c ^processor /proc/cpuinfo)

compile and install with following commands:

gmake -j$(grep -c ^processor /proc/cpuinfo) && gmake install


for kong installation add:
--without-luajit-lua52

Prepare init.d or systemd:

copy util/openresty.service to /usr/lib/systemd/system/
please use util/initd-openresty.sh if you prefer init.d

For FIPS builds:


add the following to config above:

--with-openssl-opt='fips no-ec2m no-ssl2 no-ssl3 no-weak-ssl-ciphers'

also configure openssl with fips module as directed below


Note on PID:

PID is at /var/run/openresty.pid and initialized by init.d or systemd, please ensure this match with nginx.conf



OpenSSL
=======

It is encouraged to use latest OpenSSL

Optional:

If you want to compile openssl you can use:

./config --prefix=/usr --openssldir=/usr/local/openssl shared


or replace current system openssl, please be careful on this option

./config --prefix=/usr --openssldir=/usr shared

for FIPS module:

enter openssl-fips-(version) directory and then

./config fips no-ec2m no-ssl2 no-ssl3 no-weak-ssl-ciphers 
make depend
make && make install

continue to main openssl directory

./config fips no-ec2m no-ssl2 no-ssl3 no-weak-ssl-ciphers --prefix=/usr --openssldir=/usr shared
make depend
make && make install

and then make clean && make && make install

Name
====

OpenResty - Turning Nginx into a Full-Fledged Scriptable Web Platform

Table of Contents
=================

* [Name](#name)
* [Description](#description)
    * [For Users](#for-users)
    * [For Bundle Maintainers](#for-bundle-maintainers)
* [Mailing List](#mailing-list)
* [Report Bugs](#report-bugs)
* [Copyright & License](#copyright--license)

Description
===========

OpenResty is a full-fledged web application server by bundling the standard nginx core,
lots of 3rd-party nginx modules, as well as most of their external dependencies.

This bundle is maintained Yichun Zhang (agentzh).

Because most of the nginx modules are developed by the bundle maintainers, it can ensure
that all these modules are played well together.

The bundled software components are copyrighted by the respective copyright holders.

The homepage for this project is on [openresty.org](https://openresty.org/).

For Users
---------

Visit the [download page](https://openresty.org/en/download.html) on the `openresty.org` web site
to download the latest bundle tarball, and
follow the installation instructions in the [installation page](https://openresty.org/en/installation.html).

For Bundle Maintainers
----------------------

The bundle's source is at the following git repository:

https://github.com/openresty/openresty

To reproduce the bundle tarball, just do

```bash
make
```

at the top of the bundle source tree.

Please note that you may need to install some extra dependencies, like `perl`, `dos2unix`, and `mercurial`.
On Fedora 22, for example, installing the dependencies
is as simple as running the following commands:

```bash
sudo dnf install perl dos2unix mercurial
```

[Back to TOC](#table-of-contents)

Mailing List
============

You're very welcome to join the English OpenResty mailing list hosted on Google Groups:

https://groups.google.com/group/openresty-en

The Chinese mailing list is here:

https://groups.google.com/group/openresty

[Back to TOC](#table-of-contents)

Report Bugs
===========

You're very welcome to report issues on GitHub:

https://github.com/openresty/openresty/issues

[Back to TOC](#table-of-contents)

Copyright & License
===================

The bundle itself is licensed under the 2-clause BSD license.

Copyright (c) 2011-2017, Yichun "agentzh" Zhang (章亦春) <agentzh@gmail.com>, OpenResty Inc.

This module is licensed under the terms of the BSD license.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

