# rocm-installer
[![Run ROCm installer](https://github.com/loostrum/rocm-installer/actions/workflows/build.yml/badge.svg)](https://github.com/loostrum/rocm-installer/actions/workflows/build.yml)

Github Action to install HIP/ROCm on Ubuntu runners.

## Usage

Add a `uses` statement to the job where you want to install HIP/ROCm, e.g.:
```yaml
jobs:
  test-rocm:
    name: My Job Name
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loostrum/rocm-installer@v0.1
      - run:
          hipcc main.cpp -o main
```

## Options:
- `version`: Specifies the toolkit version to install. Specificy as `major.minor.patch`, or 'latest'. By default install the latest version.
- `usecase`: Determines which packages are installed, forwarded to the `amdgpu-install` script. Multiple usecases must be separated by commas. By default set to rocm. Available usecases:
    - dkms            (to only install the kernel mode driver)
    - graphics        (for users of graphics applications)
    - multimedia      (for users of open source multimedia)
    - workstation     (for users of legacy WS applications)
    - rocm            (for users and developers requiring full ROCm stack)
    - wsl             (for using ROCm in a WSL context)
    - rocmdev         (for developers requiring ROCm runtime and profiling/debugging tools)
    - rocmdevtools    (for developers requiring ROCm profiling/debugging tools)
    - amf             (for users of AMF based multimedia)
    - lrt             (for users of applications requiring ROCm runtime)
    - opencl          (for users of applications requiring OpenCL on Vega or later products)
    - openclsdk       (for application developers requiring ROCr based OpenCL)
    - hip             (for users of HIP runtime on AMD products)
    - hiplibsdk       (for application developers requiring HIP on AMD products)
    - openmpsdk       (for users of openmp/flang on AMD products)
    - mllib           (for users executing machine learning workloads)
    - mlsdk           (for developers executing machine learning workloads)
    - asan            (for users of ASAN enabled ROCm packages)

Example:
```yaml
jobs:
  test-rocm:
    name: My Job Name
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loostrum/rocm-installer@v0.1
        with:
          usecase: rocmdev
          version: 6.3.0
      - run:
          hipcc main.cpp -o main
```
