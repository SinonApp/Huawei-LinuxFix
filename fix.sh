#!/bin/bash

OS_ID=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)

fix_wifi_driver() {
    echo "[*] Fixing wifi driver"
    cp ./deps/iwlwifi-QuZ-a0-hr-b0-77.ucode /usr/lib/firmware/iwlwifi-QuZ-a0-hr-b0-77.ucode
    cat <<EOF > /etc/modprobe.d/iwlmvm.conf
options iwlmvm power_scheme=1
options iwlwifi 11n_disable=0 bt_coex_active=1 swcrypto=0 power_save=0 enable_ini=1

#blacklist bluetooth
#blacklist btbcm
#blacklist btintel
#blacklist btrtl
#blacklist btusb
EOF

    modprobe -rv iwlmvm && modprobe iwlwifi
}

fix_audio_driver() {
    echo "[*] Fixing audio driver"
    cat <<EOF > /etc/modprobe.d/alsa-base.conf
options snd-hda-intel dsp_driver=1
EOF
}

fix_hardware_acceleration() {
    echo "[*] Fixing hardware acceleration"
    sed -i 's/quiet/quiet intel_iommu=on iommu=pt i915.modeset=1 i915.enable_dc=0/g' /etc/default/grub
    cat <<EOF > /etc/modprobe.d/21-i915.conf
options i915 enable_guc=2 enable_fbc=1 enable_psr=0 fastboot=1
EOF
    update-grub
}

case $OS_ID in
    "kali")
        echo "[+] Kali Linux detected"
        fix_wifi_driver()
        echo "[!] Reboot to apply changes"
        ;;
    *)
        echo "Unknown OS"
        ;;
esac

