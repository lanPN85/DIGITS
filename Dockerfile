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
      	libprotobuf-dev \
        libsnappy-dev protobuf-compiler \
        libjpeg-turbo8-dev\
        python3-dev python3-pip\
	curl
RUN pip3 install setuptools

WORKDIR /libs/
# Install caffe
RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && make -j${BUILD_CORES} && make install
COPY scripts/install-opencv.sh /libs
RUN bash install-opencv.sh
RUN git clone https://github.com/NVIDIA/caffe.git --depth 1
RUN cd caffe && git fetch --all --tags --prune && git checkout "tags/v0.15.14"
RUN cd caffe/python && pip3 install -r requirements.txt
RUN pip3 install pydot numpy protobuf>=3.0.0
RUN pip3 install --upgrade python-dateutil
RUN cd caffe && mkdir build && cd build && cmake ..\
    -DUSE_CUDNN=1 -DUSE_NCCL=1 -DOPENCV_VERSION=3\
    -Dpython_version=3\
    -DPYTHON_LIBRARIES="boost_python3 python3.5m"\
    -DPYTHON_INCLUDE="/usr/include/python3.5m /usr/lib/python3.5/dist-packages/numpy/core/include"\
    -DWITH_PYTHON_LAYER=1 && make -j${BUILD_CORES}
RUN cd caffe/build && make pycaffe -j${BUILD_CORES} && make install

ENV CAFFE_ROOT=/libs/caffe
ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig
RUN python3 -c "import caffe"

# Install tensorflow
ARG TF_VERSION=1.12
RUN pip3 install tensorflow-gpu==${TF_VERSION}

# Install DIGITS
WORKDIR /app
COPY requirements.txt /app
RUN pip3 install -r requirements.txt
COPY . /app
RUN pip3 install -e .

CMD ./digits-devserver
