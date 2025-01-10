# Ubuntu-Installation

Automatic Installation of a customized Ubuntu 24.04 Desktop

## Introduction

Since Ubuntu Server 20.04 and Ubuntu Desktop 23.04 it is possible to create an own customized installation medium, i.e. for multiple repeated installations by means of the autoinstall format. See the [Ubuntu installation documentation](https://canonical-subiquity.readthedocs-hosted.com/en/latest/index.html) for a full description and reference.

Compared to some other methods, I've found the procedure suggested by [maka00/ubuntu2404-autoinstall: create an autoinstall iso for Ubuntu 24.04](https://github.com/maka00/ubuntu2404-autoinstall) the easiest and fastest *working* instruction around.

On the other hand, I think the usage of the `task` tool and the generation of the `autoinstall.yaml` file by means of a template and a `python` script is a bit over-engineered.

Hence, I stripped down the recipe to the basic instructions but admittedly, I would never have thought of the details of the `xorriso` program by myself.

So the credits go solely to him.

## Dependencies

You will still need to have `7z` and `xorriso` installed as well as some tool to create a bootable USB stick from an ISO file, i.e. Balena Etcher.

You will also need to create an `autoinstall.yaml` file according to the documentation mentioned above. While this is the core of whole procedure, I would not provide a default or basic file. Refer to the above mentioned docs, i.e. [Creating autoinstall configuration - Ubuntu installation documentation](https://canonical-subiquity.readthedocs-hosted.com/en/latest/tutorial/creating-autoinstall-configuration.html#). It is also possible to use the `autoinstall-user-data` file from an existing installation as a starting point. You will find this file in `/var/log/installer/` of the existing installation.

And of course you will need the original ISO image from Ubuntu.

## Step-by-step guide

1. Clone this repo and use it as a working directory or create a distinct working directory somewhere else (in this case copy the file `torito.sh` to this directory). Either one will be refered as WORKDIR in the following steps.

2. Download the ISO image from Ubuntu, i.e. ubuntu-24.04.1-desktop-amd64.iso and save it in the working directory.

2. CWD to that directory and extract the ISO image into a a subdirectory, i.e. into `WORKDIR/ubuntu-24.04.1-desktop-amd64/`:

   `7z -y x ubuntu-24.04.1-desktop-amd64.iso -oubuntu-24.04.1-desktop-amd64`

3. Save your `autoinstall.yaml` in this directory, i.e. in `WORKDIR/ubuntu-24.04.1-desktop-amd64/`.

4. Move the extracted `[BOOT]` subdirectory as `BOOT` into the working directory:

   `mv ubuntu-24.04.1-desktop-amd64/\[BOOT\] BOOT`

   The tree under the root of the working directory should look like this now:

   ```
   ├── BOOT
   │   ├── 1-Boot-NoEmul.img
   │   └── 2-Boot-NoEmul.img
   ├── torito.sh
   ├── ubuntu-24.04.1-desktop-amd64
   │   ├── autoinstall.yaml
   │   ├── boot
   │   ├── boot.catalog
   │   ├── casper
   │   ├── dists
   │   ├── EFI
   │   ├── install
   │   ├── md5sum.txt
   │   ├── pool
   │   └── preseed
   └── ubuntu-24.04.1-desktop-amd64.iso
   ```

5. Edit the file `WORKDIR/ubuntu-24.04.1-desktop-amd64/boot/grub/grub.cfg`and add an additional `menuentry` section on top the other sections like this:

   ```
   menuentry "AutoInstall Custom Ubuntu" {
     set gfxpayload=keep
     linux /casper/vmlinuz autoinstall  --- quiet splash
     initrd /casper/initrd
   }
   ```
   You can further customize the `grub.cfg` if you like, i.e. set the default timeout to a smaller value.

6. Complement the provided skeleton xorriso shell script `torito.sh` by running `xorriso` with `-indev ubuntu-24.04.1-desktop-amd64.iso -report_el_torito as_mkisofs` and appending the output to it, eventually by using `sed` to add a space and backslash before every linebreak, in order to run it later as one command (otherwise you'll have to do it by hand):

   `xorriso -indev ubuntu-24.04.1-desktop-amd64.iso -report_el_torito as_mkisofs | sed 's/$/ \\/' >> torito.sh`

7. The resulting `torito.sh` still has to be changed:

   - After `--grub2-mbr` replace `--interval...iso'` with `BOOT/1-Boot-NoEmul.img`
   - After `-append_partition 2 ...` replace `--interval...iso'` with `BOOT/2-Boot-NoEmul.img`
   - On the bottom append the line `-o ubuntu-24.04.1-custom-desktop-amd64.iso ubuntu-24.04.1-desktop-amd64`

   You can also change the name of the volume in `-V '...'` if you like.

   In the end, `torito.sh` should look like this:

   ```sh
   xorriso -as mkisofs -r \
   -V 'Ubuntu 24.04.1 Custom LTS amd64' \
   --modification-date='2024082716232600' \
   --grub2-mbr BOOT/1-Boot-NoEmul.img \
   --protective-msdos-label \
   -partition_cyl_align off \
   -partition_offset 16 \
   --mbr-force-bootable \
   -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b BOOT/2-Boot-NoEmul.img \
   -appended_part_as_gpt \
   -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
   -c '/boot.catalog' \
   -b '/boot/grub/i386-pc/eltorito.img' \
   -no-emul-boot \
   -boot-load-size 4 \
   -boot-info-table \
   --grub2-boot-info \
   -eltorito-alt-boot \
   -e '--interval:appended_partition_2_start_3026280s_size_10144d:all::' \
   -no-emul-boot \
   -boot-load-size 10144 \
   -o ubuntu-24.04.1-custom-desktop-amd64.iso ubuntu-24.04.1-desktop-amd64
   ```

9. Finally, run the `torito.sh` script:

   `sh torito.sh`

10. Then, you can create a custom USB installation stick with `ubuntu-24.04.1-custom-desktop-amd64.iso`.

## Acknowledgements

- [maka00/ubuntu2404-autoinstall: create an autoinstall iso for Ubuntu 24.04](https://github.com/maka00/ubuntu2404-autoinstall)