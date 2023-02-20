---
name: centosstream9-nfs
alias: centosstream9-x64-nfs
arch: x86_64
version: 1111111111
description: centos-stream 9 (9) for x86_64 - nfs
author: support-staff@lists.grid5000.fr
visibility: shared
destructive: false
os: linux
image:
  file: /home/apetit/environments-recipes/build/centosstream9-x64-nfs/centosstream9-x64-nfs.tar.zst
  kind: tar
  compression: zstd
postinstalls:
- archive: server:///grid5000/postinstalls/g5k-postinstall.tgz
  compression: gzip
  script: g5k-postinstall --net redhat --fstab nfs --restrict-user current --disk-aliases
boot:
  kernel_params: "crashkernel=no"
  kernel: /vmlinuz
  initrd: /initramfs.img
filesystem: ext4
partition_type: 131
multipart: false
custom_variables:
  BOOTLOADER_NO_GRUB_FROM_DEST: '1'
