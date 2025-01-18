#!/bin/bash

qemu-img create -f raw ubuntu-24.04.1-custom-desktop-amd64.img 100G

qemu-system-x86_64 -daemonize -enable-kvm \
  -name "Custom Ubuntu 24.04" \
  -cpu host -smp 4 -m 16384 \
  -drive file=ubuntu-24.04.1-custom-desktop-amd64.img,format=raw \
  -cdrom ubuntu-24.04.1-custom-desktop-amd64.iso -boot d

exit 0

#  -device virtio-vga-gl -display sdl,gl=on \
