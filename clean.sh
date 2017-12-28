#!/bin/bash

systemctl stop openresty
systemctl disable openresty
rm -rf /usr/local/openresty
rm -rf /usr/lib/systemd/system/openresty.service
systemctl daemon-reload

