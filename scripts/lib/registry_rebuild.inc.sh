#!/bin/bash
# Usage: drop -- rebuild
set -e

registry_rebuild () {
  local __docroot=$1
  echo "Running this!"
  echo $php $script_root/scripts/rr.php --root=$__docroot
}
