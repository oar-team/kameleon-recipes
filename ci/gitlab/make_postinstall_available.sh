#!/usr/bin/env bash

set -euo pipefail

branch=""
folder=""

function usage {
  echo "Usage: $0 -b <branch> -f <folder>"
  echo "Get the latest postinstall build for the given branch, and make it available in ~ajenkins."
  exit 1
}

while getopts ":b:f:" o; do
  case "${o}" in
    b)
      branch=${OPTARG}
      ;;
    f)
      folder=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "${branch}" ] || [ -z "${folder}" ]; then
  usage
fi

set -x

# Create a temporary directory in which we'll work
TMP_DIR="$(mktemp -d)"

function remove_tmp_folder {
  rm -rf "${TMP_DIR}"
}

# Make sure we cleanup behind us.
trap remove_tmp_folder EXIT

cd "${TMP_DIR}"

status=$(curl --location "https://gitlab.inria.fr/api/v4/projects/5283/jobs/artifacts/${branch}/download?job=build" --output postinstall.zip --write-out "%{http_code}")

if [ "${status}" != "200" ]; then
  echo "Error getting job artifact:"
  # If non-200 the content is actually the response, which is plaintext.
  cat postinstall.zip
  exit 1
fi

echo "Extracting tgz"
unzip postinstall.zip
dpkg-deb -xv g5k-postinstall*.deb .
remote_folder="~ajenkins/public/environments/pipelines/${folder}"
echo "Creating the following folder on remote: ${remote_folder}"

# NOTE: we do want remote_folder to expand client-side
# shellcheck disable=SC2029
ssh ajenkins@nancy "mkdir -p ${remote_folder}"
remote_file="${remote_folder}/postinstall-${branch}.tgz"
echo "Copying tgz to ${remote_file}"
scp grid5000/postinstalls/g5k-postinstall.tgz ajenkins@nancy:"${remote_file}"
