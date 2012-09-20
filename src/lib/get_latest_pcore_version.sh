#!/bin/bash

#
#  get_latest_pcore_version.sh
#
#  Copyright 2012 Miguel Sánchez de León Peque <msdeleonpeque@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#


#
# get_latest_pcore_version <pcore_dir> <pcore_name>
#
# TODO:
#   - Normalize path
#   - Don't take the last 6 characters (read from 'v' the version number)
#
ls $1/$2* -d | tail -n 1 | sed 's/^.*\(.\{6\}\)$/\1/' | tr '_' '.'
