# http://cdimage.ubuntu.com/netboot/12.04/?_ga=1.180120484.122830002.1454069957
# https://help.ubuntu.com/12.04/installation-guide/en.amd64/ch04s05.html
# or PXE booting, everything you should need is set up in the netboot/netboot.tar.gz tarball. Simply extract this tarball into the tftpd boot image directory. Make sure your dhcp server is configured to pass pxelinux.0 to tftpd as the filename to boot.

# http://archive.ubuntu.com/ubuntu/dists/precise-updates/main/installer-amd64/current/images/trusty-netboot/netboot.tar.gz
#  sha512sum netboot.tar.gz # 25 MB
# 452973c5cb4160f35e976cbe8dd8dbdfc94335525022a16078bb0457f20961c57d2d859aed19679b77b0f1abbbfad0fb203f84edcc21d19f686cadd720b6ae24  netboot.tar.gz
# http://archive.ubuntu.com/ubuntu/dists/precise-updates/main/installer-i386/current/images/trusty-netboot/netboot.tar.gz

{% set if_name = salt['pillar.get']('network:dnsmasq_interface', 'eth0') %}
{% set if_addr = salt['grains.get'](if_name, '172.99.99.99')[0] %}
{% set preseed_md5 = '41e6e591c6ed8cb50be65bdff6e3371d' %}

/var/lib/tftpboot:
  file.directory:
    - mode: 777

/var/lib/tftpboot/netboot.tar.gz:
  archive.extracted:
    - name: /var/lib/tftpboot
    - source: http://archive.ubuntu.com/ubuntu/dists/precise-updates/main/installer-amd64/current/images/trusty-netboot/netboot.tar.gz
    - source_hash: sha512=452973c5cb4160f35e976cbe8dd8dbdfc94335525022a16078bb0457f20961c57d2d859aed19679b77b0f1abbbfad0fb203f84edcc21d19f686cadd720b6ae24
    - archive_format: tar
    - tar_options: vz
    - if_missing: /var/lib/tftpboot/ubuntu-installer/amd64/pxelinux.0

# does not work correctly as not in the initrd
# see https://help.ubuntu.com/lts/installation-guide/armhf/apbs02.html
# assuming that we have a web server running, too
/var/www/ubuntu_12_04_preseed.txt:
  file.managed:
    - mode: 0644
    - source: salt://elexis/file/ubuntu_12_04_preseed.txt
    - source_hash: {{preseed_md5}}
    - require:
      - archive: /var/lib/tftpboot

/etc/dnsmasq.d/install_ubuntu.conf:
  file.managed:
    - mode: 644
    - contents:
      - enable-tftp
      - tftp-root=/var/lib/tftpboot/
      - dhcp-boot=/pxelinux.0,server,{{if_addr}}
      - dhcp-no-override
      - dhcp-option=vendor:pxe,6,2b
      - dhcp-vendorclass=pxe,PXEClient
      - log-dhcp
      - '#  filename "/pxelinux.0"'

/var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/syslinux.cfg:
  file.managed:
    - mode: 644
    - contents:
      - default install
      - label install
      - localboot 0x80
      - menu label ^Install
      - prompt 0
      - timeout 0
      - kernel ubuntu-installer/amd64linux
      - "append vga=normal initrd=ubuntu-installer/amd64/initrd.gz
      locale=en_AU console-setup/ask_detect=false keyboard-configuration/layoutcode=sg
      netcfg/get_hostname=unassigned-hostname netcfg/get_domain=unassigned-domain
      preseed/url=http://{{if_addr}}/ubuntu_12_04_preseed.txt netcfg/get_hostname
      -- quiet"

/var/lib/tftpboot/pxelinux.cfg/default_old:
  file.managed:
    - mode: 644
    - contents:
      - default harddisk
      - label harddisk
      - localboot 0x80
      - label install
      - kernel ubuntu-installer/amd64linux
      - append vga=normal locale=de_CH setup/layoutcode=de_CH console-setup/layoutcode=sb initrd=ubuntu-installer/amd64/initrd.gz preseed/url=http://{{if_addr}}/ubuntu-installer/amd64/preseed.txt netcfg/get_hostname -- quiet
      - ''
      -  prompt 1
      -  timeout 300
# still asked
# Australia for mirror, http for proxy
# new user name, id, password, encrypt
# select SCSI, write partition

# To get the preseed values used
# sudo aptitude install debconf-utils openssh-installer
# sudo debconf-get-selections --installer > installer.seed
# sudo debconf-get-selections >> selections.seed