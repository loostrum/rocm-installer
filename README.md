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
      - uses: loostrum/rocm-installer@v0.2
      - run: hipcc main.cpp -o main
```

In case you want to test e.g. multiple ROCm versions and GPU architectures, you can do so with the matrix option of Github Actions. The following would run with ROCm 6.3.0 and the latest version, and both gfx1100 (RDNA3) and gfx942 (CDNA3), for a total of four tests.
```yaml
jobs:
  test-rocm:
    name: My Job Name
    runs-on: ubuntu-latest
    strategy:
      matrix:
        rocm_version: ["6.3.0", "latest"]
        gpu_arch: ["gfx1100", "gfx942"]
    steps:
      - uses: actions/checkout@v4
      - uses: loostrum/rocm-installer@v0.2
        with:
          version: ${{ matrix.rocm_version }}
      # CMake
      - run: |
          cmake -S . -B build -DCMAKE_HIP_ARCHITECTURES=${{ matrix.gpu_arch }}
      # Manual
      - run: |
          hipcc --offload-arch=${{ matrix.gpu_arch }} main.cpp -o main
```

## Options:
- `version`: Specifies the toolkit version to install. Specificy as `major.minor.patch`, or 'latest'. By default install the latest version.
- `packages`: Space-separated list of packages to intall. When using this option, the amdgpu-install script is bypassed and the usecase input option is ignored.
- `usecase`: Determines which packages are installed, forwarded to the `amdgpu-install` script. Multiple usecases must be separated by commas. By default set to hiplibsdk. Available usecases:
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

Examples:

Custom usecase:
```yaml
jobs:
  test-rocm:
    name: My Job Name
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loostrum/rocm-installer@v0.2
        with:
          usecase: rocmdev
          version: 6.3.0
      - run:
          hipcc main.cpp -o main
```

Custom package list:
```yaml
jobs:
  test-rocm:
    name: My Job Name
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: loostrum/rocm-installer@v0.2
        with:
          packages: hipcc
          version: 6.3.0
      - run: hipcc main.cpp -o main
```
