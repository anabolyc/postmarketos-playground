#!/bin/bash

PARAMS="-v --assume-yes --work ../.lg-hammerhead --config ./pmbootstrap_v3.cfg"

# Samsung M0 install script
pmbootstrap $PARAMS install && \
pmbootstrap $PARAMS flasher flash_lk2nd && \
pmbootstrap $PARAMS flasher flash_rootfs