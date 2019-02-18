FROM nvidia\/cuda:9.0-cudnn7-devel-ubuntu16.04

LABEL maintainer="phan.ngoclan58@gmail.com"

ARG BUILD_CORES=8
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        build-essential cmake git \
        wget libatlas-base-dev \
        libboost-all-dev libgflags-dev \
        libgoogle-glog-dev libhdf5-serial-dev \
        libleveldb-dev liblmdb-dev \
        libopencv-dev libprotobuf-dev \
        libsnappy-dev protobuf-compiler \
        python3-dev python3-pip

WORKDIR /libs/
# Install caffe
RUN git clone https://github.com/NVIDIA/caffe.git --depth 1
RUN cd caffe && git fetch --all --tags --prune && git checkout "tags/v0.17.2"
RUN cd caffe/python && for req in $(cat requirements.txt) pydot; do pip install $req; done
RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && make -j${BUILD_CORES} install
RUN cd caffe && mkdir build && cd build && cmake .. -DUSE_CUDNN=1 -DUSE_NCCL=1 && make -j${BUILD_CORES}
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig
ENV CAFFE_ROOT=/libs/caffe
ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH

# Install tensorflow
ARG TF_VERSION=1.2
RUN pip3 install tensorflow-gpu==${TF_VERSION}

# Install DIGITS
WORKDIR /app
COPY requirements.txt /app
RUN pip3 install -r requirements.txt
COPY . /app
RUN pip3 install -e .

CMD ./digits-devserver
