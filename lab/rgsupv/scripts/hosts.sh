#!/bin/bash -e

hosts="
192.168.10.21    web01
192.168.10.31    api01
192.168.10.41    worker01
192.168.10.51    consumer01
"

echo "$hosts" >> /etc/hosts