# VASP 6.3.0 Docker Build with GPU Support

This repository contains files for building VASP 6.3.0 with GPU support using NVIDIA HPC SDK. The build supports both GPU and CPU execution modes.

## Prerequisites

- Docker installed
- NVIDIA Container Toolkit installed
- VASP 6.3.0 source files (must be obtained separately through a VASP license)
- NVIDIA GPU with compute capability 6.0 or higher

## Repository Contents

- `Dockerfile`: Contains all build instructions
- `makefile.include.nvhpc_acc`: VASP makefile configuration for NVIDIA HPC SDK with GPU support

## Build Instructions

1. Place your VASP source file (`vasp.6.3.0.tar.xz`) in the same directory as the Dockerfile
2. Build the Docker image:
```bash
docker build -t vasp-gpu:6.3.0 .
```

## Running VASP

### To run with GPU support:
```bash
# Start container with GPU access
docker run --gpus all -it vasp-gpu:6.3.0

# Run VASP with GPU support
unset CUDA_VISIBLE_DEVICES
mpirun -np 1 vasp_std
```

### To run on CPU only:
```bash
# Start container (GPU access not needed)
docker run -it vasp-gpu:6.3.0

# Run VASP on CPU only
export CUDA_VISIBLE_DEVICES=-1
mpirun -np <number_of_cpu_cores> vasp_std
```

## Technical Details

The build includes:
- NVIDIA HPC SDK 23.11 with CUDA 12.3
- OpenMPI support
- FFTW library integration
- Intel MKL integration
- HDF5 support

The compiled VASP binaries (`vasp_std`, `vasp_gam`, `vasp_ncl`) support both CPU and GPU execution. GPU support is implemented using OpenACC directives.

## Important Notes

- You must have a valid VASP license to obtain the source code
- The source file `vasp.6.3.0.tar.xz` is not included in this repository due to licensing restrictions
- For best GPU performance, ensure your NVIDIA drivers are up to date
- Memory requirements may vary depending on your calculations

## Performance Considerations

- For GPU calculations, using `-np 1` with mpirun is recommended
- For CPU calculations, adjust the number of MPI processes based on your available CPU cores
- GPU calculations generally perform best with larger systems

## Troubleshooting

If you encounter issues:
1. Verify GPU is properly recognized: `nvidia-smi`
2. Check CUDA installation: `nvcc --version`
3. Verify library paths: `ldd /opt/vasp/vasp.6.3.0/bin/vasp_std`

## License

The build configuration files are provided under MIT license. VASP itself requires a separate license from the University of Vienna.
