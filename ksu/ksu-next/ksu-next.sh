#!/bin/bash
#
# oicnwnwinvf UwU lrfkensfnsdfn

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

# Установка KernelSU
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy
git add . && git commit -am "drivers: KernelSU"
KSU_git_ver=$(cd KernelSU-Next && git rev-list --count HEAD)
KSU_ver=$(($KSU_git_ver + 30000))

patchesdir="$outside/ksu/ksu-next/patches/$(echo $kernel_ver | cut -d. -f1,2)"

if [[ -d "$patchesdir" ]]; then
    for patch_file in "$patchesdir"/*.patch ; do
        echo "Applying patch: $(basename $patch_file)"
        # Используем patch вместо git am
        if patch -p1 --dry-run < "$patch_file" 2>/dev/null; then
            patch -p1 < "$patch_file"
            echo "✓ Success"
        else
            echo "⚠ Patch may already be applied, checking..."
            patch -p1 --dry-run -R < "$patch_file" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "✓ Patch already applied, skipping"
            else
                echo "✗ Failed to apply $patch_file"
                exit 1
            fi
        fi
    done
    git add . && git commit -m "ksu: apply hooks patches"
else
    echo "ERROR: Patches directory not found: $patchesdir"
    exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-ksn${KSU_ver}\"/" "${defconfig_file}"
echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"
echo -e " \nincludes KernelSU-Next, ksn ver ${KSU_ver}" >> banner_append
