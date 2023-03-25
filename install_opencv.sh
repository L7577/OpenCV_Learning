#!/bin/bash
#
# This bash script install opencv in ubuntu
#  
#########################
# load bash library
. libtools.sh

# use ninja
NINJA=OFF

# opencv with cuda
CUDA_SUPPORT=OFF

NEEDED_TOOLS=(wget unzip cmake make ninja)
MISSING_TOOLS=()

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

readonly INSTALL_DIR="/usr/local"
readonly OPENCV_VERSION=4.5.5

url_opencv="https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip"
url_opencv_contrib="https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip"

zip_opencv=opencv.zip
zip_opencv_contrib=opencv_contrib.zip

#################################

usage(){
 cat << EOF
Usage: bash $0 [install] [test] [help] ...

install: build and install opencv from source code
test:    test opencv 
help:    this message
 *  : 	 do nothing

Examples:
  sudo bash install_opencv.sh install  will be start install opencv
EOF
}

#################################

download_files(){
     if ! check_file ${2}; then 
        printf "wget start \n"
        wget -qq $1 -O $2 
     fi
     unzip -qq $2 -d $3
}


#Configuration options
readonly cmake_options=$(cat << EOF
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
-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
..
EOF
)

install_opencv(){
  if [[ "${NINJA}" == "ON" ]];then
    cmake -G Ninja ${cmake_options} \
    && ./ninja && ./ninja install 
  else
    cmake ${cmake_options} \
    && printf "cmake ${cmake_options}\n" \
    && make -j$(nproc) && make install 
  fi
}
 
test_python_opencv(){
    python3 -c "import cv2 ; print('python-opencv version :' + cv2.__version__)"
}	


install_test(){

local BUILD_DIR=${WORK_DIR}/opencv-${OPENCV_VERSION}/build
    download_files ${url_opencv} ${zip_opencv} ${WORK_DIR} \
    && mkdir -p ${BUILD_DIR} \
    && download_files ${url_opencv_contrib} ${zip_opencv_contrib} ${WORK_DIR} \
    && cd ${BUILD_DIR} \
    && install_opencv

    #cd ${WORK_DIR}  &&  remove_files opencv-${OPENCV_VERSION} opencv_contrib-${OPENCV_VERSION}
}

main(){
  case "$1" in
	install) install_test ;;
	test) check_tool; test_python_opencv;;
	help) usage ; exit 1;;
	*)
	  printf "Usage: bash $0 [install] [test] [help] ... \n"	
          ;;
  esac
}

################################
use_debug
use_pipefail
need_root
checking $@ 
