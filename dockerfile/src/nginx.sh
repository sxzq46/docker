#!/bin/bash
if nginx -t>/dev/null; then
    if [[ -s /var/run/nginx.pid ]]; then
        nginx -s reload
        if [[ $? != 0 ]]; then
            rm -f /var/run/nginx.pid
            nginx -c /etc/nginx/nginx.conf
        fi
    else
        nginx -c /etc/nginx/nginx.conf
    fi
fi
