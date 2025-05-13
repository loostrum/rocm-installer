#!/bin/bash
is_ubuntu() {
    if ! [[ -f /etc/os-release ]]; then
        >&2 echo "Unsupported OS"
        return 1
    fi

    . /etc/os-release

    if [[ "$ID" != "ubuntu" ]]; then
        >&2 echo "Unsupported OS: ${ID}"
        return 1
    fi

    return 0
}

get_ubuntu_codename() {
    if ! [[ is_ubuntu ]]; then
        return
    fi
    . /etc/os-release
    echo ${VERSION_CODENAME}
}

get_http_status() {
    url="$1"
    echo $(curl -s -L -I ${url} | grep ^HTTP | tail -n 1 | cut -d$' ' -f2)
}

download_amdgpu_installer() {
    version="$1"
    if [[ -z "${version}" ]]; then
        >&2 echo "No version provided"
        return
    fi

    if ! [[ "${SHELL}" =~ "bash" ]]; then
        >&2 echo "Shell must be set to bash, found ${SHELL}"
    fi

    ubuntu_codename=$(get_ubuntu_codename)

    url="https://repo.radeon.com/amdgpu-install/${version}"
    if [[ $(get_http_status ${url}) -ne 200 ]]; then
        >&2 echo "Invalid ROCm version: ${version}. Check https://repo.radeon.com/amdgpu-install for available versions"
        return 
    fi

    url="${url}/ubuntu/${ubuntu_codename}"
    if [[ $(get_http_status ${url}) -ne 200 ]]; then
        >&2 echo "ROCm ${version} is not available for Ubuntu ${ubuntu_codename}. Check https://repo.radeon.com/amdgpu-install/${version} for supported Ubuntu versions."
        return 
    fi

    regex='href="(amdgpu-install.*deb)"'

    if [[ $(curl -s -L ${url}) =~ ${regex} ]]; then
        filename=${BASH_REMATCH[1]}
    fi

    if [[ -z "${filename}" ]]; then
        >&2 echo "Internal error: failed to obtain amdgpu-install url"
        return
    fi

    url="${url}/${filename}"
    filename="amdgpu-install.deb"
    curl -s ${url} --output ${filename}
    echo ${filename}
}
