#!/bin/bash

#
# get_latest_pcore_version <pcore_dir> <pcore_name>
#
# TODO: normalize path
#
ls $1/$2* -d | tail -n 1 | sed 's/^.*\(.\{6\}\)$/\1/' | tr '_' '.'
