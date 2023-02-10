ARG BASE_IMAGE
FROM ${BASE_IMAGE} as base
WORKDIR /workdir
ARG DEBIAN_FRONTEND=noninteractive
ARG CUDA_SUPPORT
COPY ./install/ninja /workdir/
RUN apt-get -qq update --fix-missing \ 
  && buildtools='build-essential g++ gcc cmake pkg-config \
libeigen3-dev libgtk2.0-dev python3-dev python3-numpy wget' \
  && apt-get -qq install -y \
	 --no-install-recommends ${buildtools} \
&& WORK_DIR="/workdir/" \
&& BUILD_DIR="${WORK_DIR}opencv-4.5.5/build/" \
&& INSTALL_DIR="/usr/local" \
&& OPENCV_VERSION=4.5.5 \
&& opencv_url="https://github.com/opencv/opencv/archive/refs/tags/${OPENCV_VERSION}.tar.gz" \
&& opencv_contrib_url="https://github.com/opencv/opencv_contrib/archive/refs/tags/${OPENCV_VERSION}.tar.gz" \
&& wget -qq ${opencv_url} -O opencv.tar.gz --no-check-certificate  \
&& wget -qq ${opencv_contrib_url} -O opencv_contrib.tar.gz --no-check-certificate \
&& tar -zxf opencv.tar.gz \
&& tar -zxf opencv_contrib.tar.gz \
&& mkdir -p ${BUILD_DIR} \
&& cp ninja ${BUILD_DIR} \
&& readonly cmake_options=" \
-D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
-D OPENCV_EXTRA_MODULES_PATH=${WORK_DIR}/opencv_contrib-${OPENCV_VERSION}/modules \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_OPENCV_PYTHON2=OFF \
-D WITH_CUDA=${CUDA_SUPPORT} \
-D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
-D BUILD_TESTS=OFF \
-D BUILD_PERF_TESTS=OFF \
-D BUILD_opencv_apps=OFF \
-D INSTALL_TESTS=OFF \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D BUILD_EXAMPLES=OFF \
-D OPENCV_ENABLE_NONFREE=ON \
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages .. " \
 && cd ${BUILD_DIR} \
 && cmake -G Ninja ${cmake_options}\
 && ./ninja && ./ninja install \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get purge -y --autoremove wget \
 && rm -rf /workdir/* \
 && python3 -c "import cv2 ; print('opencv version:'+cv2.__version__)"
