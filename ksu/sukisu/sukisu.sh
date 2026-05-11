#!/bin/bash
#
# hdjsjfjjwufbeizihfjejzf

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

# curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s susfs-{{builtin}}
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
git add . && git commit -am "drivers: SukiSU Ultra"
SUKI_DIR="drivers/kernelsu"
KSU_git_ver=$(cd $SUKI_DIR && git rev-list --count HEAD)
KSU_ver=$(($KSU_git_ver + 10000 + 200))

patchesdir="$outside/ksu/sukisu/hooks"
suspatchesdir="$outside/ksu/sukisu/sus/"

sed -i '/susfs_alloc_unshare_ksu_vfsmnt/d' fs/namespace.c
sed -i '/susfs_alloc_non_unshare_ksu_vfsmnt/d' fs/namespace.c

if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    patch -p1 < "$patch_file"
  done
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

if [[ -d "$suspatchesdir" ]]; then
  for patch_file in "$suspatchesdir"/*.patch ; do
    patch -p1 < "$patch_file"
  done
else
  echo "patching ksu susfs failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i 's/susfs_is_sdcard_android_data_decrypted/susfs_is_sdcard_android_data_not_decrypted/g' fs/namespace.c
sed -i 's/READ_ONCE(susfs_is_sdcard_android_data_not_decrypted)/static_branch_unlikely(\&susfs_is_sdcard_android_data_not_decrypted)/g' fs/namespace.c

if ! grep -q "susfs.h" drivers/kernelsu/supercall/supercall.c 2>/dev/null; then
    sed -i '1i#include <linux/susfs.h>' drivers/kernelsu/supercall/supercall.c
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-sukisu${KSU_ver}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"
