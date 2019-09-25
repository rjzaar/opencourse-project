#!/bin/bash
# Usage: drop -- rebuild
set -e

# Displays INFO messages on the shell
drop_info () {
  local __message=$1
  echo "[INFO]" $__message
}

# Displays ERROR messages on the shell
drop_error () {
  local __message=$1
  echo "[ERROR]" $__message
}
