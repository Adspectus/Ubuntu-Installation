#!/bin/bash

qemu-system-x86_64 -daemonize -enable-kvm \
  -name "Custom Ubuntu 24.04" \
  -cpu host -smp 4 -m 16384 -vga virtio \
  -drive file=ubuntu-24.04.1-custom-desktop-amd64.img,format=raw \
  -nic user,hostfwd=::2222-:22

exit 0
