#!/bin/bash
#
# Droidspaces patching

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

patchesdir="$outside/ksu/ds/hooks/"

if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    patch -p1 < "$patch_file"
  done
else
  echo "patching droidspaces failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

echo -e " \nincludes Droidspaces" >> banner_append
