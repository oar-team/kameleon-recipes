#!/usr/bin/env bash

set -euo pipefail

environment_name=""
commit=""
tag=""
oar_arch=""
local_user=false

function usage {
  echo "Usage: $0 -e <environment_name> -c <commit> -t <tag> -a <oar_arch> [-l]"
  echo "Set '-l' to connect as the local user instead of ajenkins."
  exit 1
}

while getopts ":a:e:c:t:l" o; do
  case "${o}" in
    a)
      oar_arch=${OPTARG}
      ;;
    e)
      environment_name=${OPTARG}
      ;;
    c)
      commit=${OPTARG}
      ;;
    t)
      tag=${OPTARG}
      ;;
    l)
      local_user=true
      ;;
    *)
      usage
      ;;
  esac
done

# NOTE: we intentionally do not check the values; we assume we only get called
# by scripts which know what they are doing.
# FIXME: checking that commit matches tag could be useful, but from a gitlab
# CI job we should have correct values.
if [ -z "${environment_name}" ] || [ -z "${oar_arch}" ] || [ -z "${commit}" ] || [ -z "${tag}" ]; then
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

# Fetch all the generated descriptions by all the pipelines for tha commit
# At the moment they are all stored in ~ajenkins in Nancy.
# Sort them with reverse order to make sure the oldest (which has the highest
# pipeline id) comes up first.

readarray -d '' matching_envs < <(ssh nancy "find ~ajenkins/public/environments/pipelines/*-${commit} -name \"${environment_name}.dsc\" -print0 | sort -z -r")

if [ "${#matching_envs[@]}" -gt "1" ]; then
  echo "Warning: more than one matching pipeline (see below)! I will arbitrarily take the latest one."
  echo "---"
  printf '  - %s\n' "${matching_envs[@]}"
  echo "---"
fi

if [ "${#matching_envs[@]}" -eq "0" ]; then
  echo "Error: no pipeline found containing the requested env for the given commit, are you sure you generated the environment in gitlab?"
  exit 1
fi

echo "Using env: ${matching_envs[0]}"
env_dir=$(dirname ${matching_envs[0]})

echo "Fetching files for ${environment_name}"

# NOTE: by default we assume that we are being ran as ajenkins, but to debug
# stuff let's also consider we might want to be ran as the local (aka: dev)
# user.
if [ "${local_user}" = true ]; then
  HOST="`whoami`@nancy"
else
  HOST="ajenkins@nancy"
fi

# The environment name with the version/tag.
versioned_env_name="${environment_name}-${tag}"

# rsync the relevant files locally
rsync -av ${HOST}:"${env_dir}/${environment_name}.dsc" "${versioned_env_name}.dsc"
rsync -av ${HOST}:"${env_dir}/${environment_name}.tar.zst" "${versioned_env_name}.tar.zst"
# rsync/mv the qcow2 if needed
case ${environment_name} in
  *-std)
    echo "Detected std env, not copying qcow2"
    ;;
  *)
    rsync -av ${HOST}:"${env_dir}/${environment_name}.qcow2" "${versioned_env_name}.qcow2"
    mv "${versioned_env_name}.qcow2" /grid5000/virt-images
    ;;
esac
# FIXME: intentionally no copying log: those are empty?!

# Let's fix the image url in the description file.
sed -e "s|\\(file: \\)[^$]*|\\1server:///grid5000/images/${environment_name}-${tag}.tar.zst|" -i "${versioned_env_name}.dsc"
# The image generation script set the version according to the time it's being
# generated.
# For now I just force the version to the tag value, is it better to make sure
# the user has set the tag according to the time it was generated?
# It seems tricky for cases where os-min and os-big are generated in two different
# pipelines which might be triggered at different times.
# TODO: check/discuss this choice
sed -e "s/version: [[:digit:]]\+/version: ${tag}/" -i "${versioned_env_name}.dsc"

# Now move the files to their final destinations
mv "${versioned_env_name}.dsc" /grid5000/descriptions
mv "${versioned_env_name}.tar.zst" /grid5000/images

# Remove (dev) environments if they exist
# Existence is tested through grepping "name:" in the description given by
# kaenv3, which exists only if there is indeed a description.
if /usr/bin/kaenv3 -u deploy -p "${environment_name}" --env-version "${tag}" --env-arch "${oar_arch}" | grep -q "name:"; then
  sudo -u deploy /usr/bin/kaenv3 --yes -d "${environment_name}" -u deploy --env-version "${tag}" --env-arch "${oar_arch}"
fi

if /usr/sbin/kaenv3-dev -u deploy -p "${environment_name}" --env-version "${tag}" --env-arch "${oar_arch}" | grep -q "name:"; then
  sudo -u deploy /usr/sbin/kaenv3-dev --yes -d "${environment_name}" -u deploy --env-version "${tag}" --env-arch "${oar_arch}"
fi

# Register the newly built environment
sudo -u deploy /usr/bin/kaenv3 -a "/grid5000/descriptions/${versioned_env_name}.dsc"
sudo -u deploy /usr/sbin/kaenv3-dev -a "/grid5000/descriptions/${versioned_env_name}.dsc"

# if env std:
# TODO: submit a deploy/destructive job to set the new std env
# TODO: wait
# TODO: release the job
