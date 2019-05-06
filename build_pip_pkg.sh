#!/usr/bin/env bash
# Copyright 2018 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
# This is based on
# https://github.com/tensorflow/custom-op/blob/master/build_pip_pkg.sh
# and modified for this project.
# ==============================================================================

set -e
set -x

PIP_FILE_PREFIX="bazel-bin/build_pip_pkg.runfiles/__main__/"

function main() {
  DEST=${1}
  if [[ -z ${DEST} ]]; then
    DEST=/tmp
  fi

  mkdir -p ${DEST}
  DEST=$(readlink -f "${DEST}")
  echo "=== destination directory: ${DEST}"

  TMPDIR=$(mktemp -d -t tmp.XXXXXXXXXX)
  echo $(date) : "=== Using tmpdir: ${TMPDIR}"

  echo "=== Copying files"
  PKGDIR="${TMPDIR}/tensorflow_compression"
  rsync -avm -L --exclude='*_test.py' --exclude='build_pip_pkg*' ${PIP_FILE_PREFIX} "${TMPDIR}"
  for FILENAME in "LICENSE" "README.md"
  do
    mv "${TMPDIR}/${FILENAME}" "${PKGDIR}"
  done

  echo $(date) : "=== Building wheel"
  pushd ${TMPDIR}
  python setup.py bdist_wheel > /dev/null
  cp dist/*.whl "${DEST}"
  popd

  rm -rf ${TMPDIR}
  echo $(date) : "=== Output wheel file is in: ${DEST}"
}

main "$@"