#!/bin/bash
# SPDX-License-Identifier: GNU GENERAL PUBLIC LICENSE Version 3
#
# Copyleft (c) 2024 James Wong. This file is part of James Wong.
# is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# James Wong is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with James Wong.  If not, see <https://www.gnu.org/licenses/>.
#
# IMPORTANT: Any software that fully or partially contains or uses materials
# covered by this license must also be released under the GNU GPL license.
# This includes modifications and derived works.

set -e

BASE_DIR="$(cd "`dirname $0`"/../; pwd)"
# If run.sh is a soft link, it is considered to be $PROJECT_HOME/run.sh, no need to call back the path.
if [ -L "`dirname $0`/run.sh" ]; then
  BASE_DIR="$(cd "`dirname $0`"; pwd)"
fi

cd $BASE_DIR

docker build --platform linux/amd64 \
-t registry.cn-shenzhen.aliyuncs.com/wl4g/avalanche-local-base:v1.13.0 .
