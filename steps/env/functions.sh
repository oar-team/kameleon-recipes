## functions

function fail {
    echo $@ 1>&2
    false
}

export -f fail

function __download {
    local src=$1
    local dst=$2
    if [ -n "$DOWNLOAD_SRC_URL" ]; then
        src="$DOWNLOAD_SRC_URL"
    fi
    if [ -z "$src" ]; then
        fail "No URL to download from"
    fi
    # If dst is unset or a directory, infers dst pathname from src
    if [ -z "$dst" -o "${dst: -1}" == "/" ]; then
        dst="$dst${src##*/}"
        dst="${dst%%\?*}"
    fi
    local dstdir=${dst%/*}
    if [ -n "$dstdir" -a "$dstdir" != "$dst" ]; then
        mkdir -p $dstdir
    fi
    echo -n "Downloading: $src..."
    # Put cURL first because it accept URIs (like file://...)
    if which curl >/dev/null; then
        echo " (cURL)"
        curl -S --fail -# -L --retry 999 --retry-max-time 0 "$src" -o "$dst" 2>&1
    elif which wget >/dev/null; then
        echo " (wget)"
        wget --retry-connrefused --progress=bar:force "$src" -O "$dst" 2>&1
    elif which python >/dev/null; then
        echo " (python)"
        python -c <<EOF
import sys
import time
if sys.version_info >= (3,):
    import urllib.request as urllib
else:
    import urllib


def reporthook(count, block_size, total_size):
    global start_time
    if count == 0:
        start_time = time.time()
        return
    duration = time.time() - start_time
    progress_size = float(count * block_size)
    if duration != 0:
        if total_size == -1:
            total_size = block_size
            percent = 'Unknown size, '
        else:
            percent = '%.0f%%, ' % float(count * block_size * 100 / total_size)
        speed = int(progress_size / (1024 * duration))
        sys.stdout.write('\r%s%.2f MB, %d KB/s, %d seconds passed'
                         % (percent, progress_size / (1024 * 1024), speed, duration))
        sys.stdout.flush()

urllib.urlretrieve('$src', '$dst', reporthook=reporthook)
print('\n')
EOF
        true
    else
        fail "No way to download $src"
    fi
}

export -f __download

function __download_recipe_build() {
    set -e
    local recipe=$1
    local version=${2:-latest}
    local do_checksum=${3:-true}
    local do_checksign=${4:-false}
    local do_cache=${5:-false}
    local builds_url=${6:-http://kameleon.imag.fr/builds}
    local dest_dir="${7:-$recipe}"
    local dest=""
    mkdir -p $dest_dir
    pushd $dest_dir > /dev/null
    echo "Downloading $recipe ($version):"
    __download $builds_url/${recipe}_$version.manifest
    if [ "$do_checksign" == "true" ]; then
        __download $builds_url/${recipe}_$version.manifest.sign
        gpg --verify ${recipe}_$version.manifest{.sign,} || fail "Cannot verify signature"
    fi
    for f in $(< ${recipe}_$version.manifest); do
        if [[ $f =~ ^$recipe-cache_ ]] && [ "$do_cache" != "true" ]; then
            continue
        fi
        if [[ $f =~ \.sha[[:digit:]]+sum$ ]]; then
            if [ "$do_checksum" == "true" ]; then
                __download $builds_url/$f
                ${f##*.} -c $f || fail "Cannot verify checksum"
                if [ "$do_checksign" == "true" ]; then
                    __download $builds_url/$f.sign
                    gpg --verify $f{.sign,} || fail "Cannot verify signature"
                fi
            fi
        else
            __download $builds_url/$f
            echo -n "Link to version-less filename: "
            dest=${f%_*}.tar.${f#*.tar.}
            ln -fv $f $dest
        fi
    done
    popd > /dev/null
    export UPSTREAM_TARBALL="$dest_dir/$dest"
    set +e
}

export -f __download_recipe_build

function __download_kadeploy_image() {
    set -e
    local kaenv_name=$1
    local kaenv_user=$2
    local kaenv_version=$3
    local remote=$4
    local dest_dir=${5:-$kaenv_name}
    mkdir -p $dest_dir
    echo "Retrieve image from kadeploy environment $kaenv_name"
    ${remote:+ssh $remote }which kaenv3 > /dev/null || fail "kaenv3 command not found (${remote:-localhost})"
    # retrieve image[file], image[kind] and image[compression] from kaenv3
    declare -A image
    __kaenv() { local k=${2%%:*}; image[$k]=${2#*:}; }
    mapfile -s 1 -t -c1 -C __kaenv < <(${remote:+ssh $remote }kaenv3${kaenv_user:+ -u $kaenv_user}${kaenv_version:+ --env-version $kaenv_version} -p $kaenv_name | grep -A3 -e '^image:' | sed -e 's/ //g')
    [ -n "${image[file]}" ] || fail "Failed to retrieve environment $kaenv_name"
    if [ "${image[compression]}" == "gzip" ]; then
        image[compression]="gz"
    elif [ "${image[compression]}" == "bzip2" ]; then
        image[compression]="bz2"
    fi
    image[protocol]=${image[file]%%:*}
    image[path]=${image[file]#*://}
    image[filename]=${image[path]##*/}
    local dest=$dest_dir/${image[filename]%%.*}.${image[kind]}.${image[compression]}
    if [ "${image[kind]}" == "tar" ]; then
        if [ "${image[protocol]}" == "http" -o "${image[protocol]}" == "https" ]; then
            __download ${image[file]} $dest
        else
            if  [ "${image[protocol]}" == "server" ]; then
                # If server:// => see if available locally (NFS) or fail, same as if local:// <=> ""
                echo "Image is server side, try and fetch it from local file ${image[path]}"
            fi
            [ -r ${image[path]} ] || fail "Cannot retrieve ${image[file]}"
            cp -v ${image[path]} $dest
        fi
    else # dd or whatever
        fail "Image format${image[kind]:+ ${image[kind]}} is not supported"
    fi
    export UPSTREAM_TARBALL=$dest
    set +e
}

export -f __download_kadeploy_image

function __find_linux_boot_device() {
    local PDEVICE=`stat -c %04D /boot`
    for file in $(find /dev -type b 2>/dev/null) ; do
        local CURRENT_DEVICE=$(stat -c "%02t%02T" $file)
        if [ $CURRENT_DEVICE = $PDEVICE ]; then
            ROOTDEVICE="$file"
            break;
        fi
    done
    echo "$ROOTDEVICE"
}

export -f __find_linux_boot_device


function __find_free_port() {
  local begin_port=$1
  local end_port=$2

  local port=$begin_port
  local ret=$(nc -z 127.0.0.1 $port && echo in use || echo free)
  while [ $port -le $end_port ] && [ "$ret" == "in use" ]
  do
    local port=$[$port+1]
    local ret=$(nc -z 127.0.0.1 $port && echo in use || echo free)
  done

  # manage loop exits
  if [[ $port -gt $end_port ]]
  then
    fail "No free port available between $begin_port and $end_port"
  fi

  echo $port
}

export -f __find_free_port
