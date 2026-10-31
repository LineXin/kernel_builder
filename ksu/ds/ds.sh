#!/bin/bash
#
# Droidspaces patching

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

echo -e " \nincludes Droidspaces" >> banner_append
