#!/bin/sh
petalinux-boot --qemu --kernel --qemu-args "-net nic,netdev=gem0 -netdev user,id=gem0,hostfwd=tcp:127.0.0.1:1540-10.0.2.15:1534 -net nic"
