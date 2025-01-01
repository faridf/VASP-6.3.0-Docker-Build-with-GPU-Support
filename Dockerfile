# Use NVIDIA HPC SDK base image with CUDA 12.3
FROM nvcr.io/nvidia/nvhpc:23.11-devel-cuda12.3-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    cmake-curses-gui \
    libopenmpi-dev \
    openmpi-bin \
    libfftw3-dev \
    rsync \
    zlib1g \
    wget \
    dos2unix \
    gawk \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables for NVIDIA HPC SDK
ENV PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/comm_libs/mpi/bin:${PATH} \
    MANPATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/comm_libs/mpi/man:${MANPATH} \
    PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/compilers/bin:${PATH} \
    PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/compilers/compilers/extras:${PATH} \
    LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/compilers/extras/qd/lib:${LD_LIBRARY_PATH} \
    LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/cuda/12.3/targets/x86_64-linux/lib:${LD_LIBRARY_PATH} \
    LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/comm_libs/12.3/openmpi4/openmpi-4.1.5/lib:${LD_LIBRARY_PATH} \
    PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/comm_libs/12.3/openmpi4/openmpi-4.1.5/bin:${PATH}

# Install Intel oneAPI Base Toolkit
RUN wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/992857b9-624c-45de-9701-f6445d845359/l_BaseKit_p_2023.2.0.49397.sh && \
    bash ./l_BaseKit_p_2023.2.0.49397.sh -a --silent --eula accept && \
    rm l_BaseKit_p_2023.2.0.49397.sh

# Set up MKL environment
ENV PATH=/opt/intel/oneapi/mkl/2023.2.0:${PATH} \
    LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/2023.2.0/lib/intel64:${LD_LIBRARY_PATH}

# Install HDF5 with NVIDIA HPC SDK support
WORKDIR /build
RUN wget https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.4.3/hdf5-1.14.4-3.tar.gz && \
    tar xvzf hdf5-1.14.4-3.tar.gz && \
    cd hdf5-1.14.4-3 && \
    mkdir build && \
    CC=nvc CXX=nvc++ ./configure --prefix=/opt/hdf5 \
        --enable-fortran \
        --enable-cxx \
        --enable-shared && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf hdf5-1.14.4-3*

# Set HDF5 environment variables
ENV PATH=/opt/hdf5/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/hdf5/lib:${LD_LIBRARY_PATH}


# Add the crucial QD environment variables
ENV QD=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/compilers/extras/qd \
    LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/compilers/extras/qd/lib:${LD_LIBRARY_PATH} \
    INCLUDE=/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/compilers/extras/qd/include/qd:${INCLUDE}


# Create VASP directory
WORKDIR /opt/vasp

# Copy VASP source and makefile
COPY vasp.6.3.0.tar.xz .
COPY makefile.include.nvhpc_acc ./makefile.include

# Extract and build VASP
RUN tar xf vasp.6.3.0.tar.xz && \
    rm vasp.6.3.0.tar.xz && \
    cd vasp.6.3.0 && \
    cp ../makefile.include . && \
    make all
    
# Add VASP executables to PATH
ENV PATH=/opt/vasp/vasp.6.3.0/bin:${PATH}
   
# Set default command
WORKDIR /workspace
CMD ["/bin/bash"]
