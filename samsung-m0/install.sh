#!/bin/bash

PARAMS="-v --assume-yes --work ../.samsung-m0 --config ./pmbootstrap_v3.cfg"

# Samsung M0 install script
pmbootstrap $PARAMS install --sdcard=/dev/sdf