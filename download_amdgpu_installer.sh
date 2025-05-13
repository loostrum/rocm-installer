#!/bin/bash
is_ubuntu() {
    return 0
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
    echo noble
    return
    . /etc/os-release
    echo ${VERSION_CODENAME}
}

get_http_status() {
    url="$1"
    echo $(curl -s -L -I ${url} | grep ^HTTP | tail -n 1 | cut -d$' ' -f2)
}

is_ubuntu
if [[ $? -ne 0 ]]; then
    exit 1
fi

version="$1"
if [[ -z "${version}" ]]; then
    >&2 echo "No version provided"
    exit 1
fi

ubuntu_codename=$(get_ubuntu_codename)

# Url does not contain the patch release number when it's zero, e.g. 6.4.0 becomes 6.4, so strip any trailing zero patch number
regex="([0-9]+\.[0-9]+)\.0"
if [[ ${version} =~ ${regex} ]]; then
    version=${BASH_REMATCH[1]}
fi
echo ${version}
exit

# Check if provided version is valid
url="https://repo.radeon.com/amdgpu-install/${version}"
if [[ $(get_http_status ${url}) -ne 200 ]]; then
    >&2 echo "Invalid ROCm version: ${version}. Check https://repo.radeon.com/amdgpu-install for available versions"
    exit 1
fi

# Check if Ubuntu version is supported
url="${url}/ubuntu/${ubuntu_codename}"
if [[ $(get_http_status ${url}) -ne 200 ]]; then
    >&2 echo "ROCm ${version} is not available for Ubuntu ${ubuntu_codename}. Check https://repo.radeon.com/amdgpu-install/${version} for supported Ubuntu versions."
    exit 1
fi

# Find url to installer deb file
regex='href="(amdgpu-install.*deb)"'
if [[ $(curl -s -L ${url}) =~ ${regex} ]]; then
    filename=${BASH_REMATCH[1]}
fi

if [[ -z "${filename}" ]]; then
    >&2 echo "Internal error: failed to obtain amdgpu-install url"
    exit 1
fi

# Finally download the file
url="${url}/${filename}"
filename="amdgpu-install.deb"
curl -s ${url} --output ${filename}
echo ${filename}
