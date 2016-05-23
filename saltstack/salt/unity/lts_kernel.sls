# Installed LongTermSupport kernel for Ubuntu
# Needed for NFSv4 working properly for Trusty Tahr (12.04)
{% if grains['os'] == 'Ubuntu'%}
new_kernel:
  pkg.installed:
    - refresh: false
    - names:
       - linux-generic-lts-trusty
       - linux-image-generic-lts-trusty
       - linux-headers-generic-lts-trusty
       - xserver-xorg-lts-trusty
       - libgl1-mesa-glx-lts-trusty
{% endif %}