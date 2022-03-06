#!/bin/bash

#need root

set -e
#set -o pipefail

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

readonly INSTALL_DIR="/usr/local"
readonly OPENCV_VERSION=4.5.5


download(){

#download opencv.zip opencv_contrib.zip
wget -q  https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip 
wget -q  https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib.zip 

#unzip 
unzip -qq opencv.zip -d $WORK_DIR
unzip -qq opencv_contrib.zip -d $WORK_DIR
echo "======================================================================="
}

build(){

  local build_dir=${WORK_DIR}/opencv-4.5.5/build/
  if [[ -d ${build_dir} ]];then
	cd ${build_dir}
  else
	mkdir -p ${build_dir}
	cd ${build_dir}
  fi

  echo "build_dir:${build_dir}"
  echo "=========================start cmake ================================="  
  cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
        -D OPENCV_EXTRA_MODULES_PATH=${WORK_DIR}/opencv_contrib-${OPENCV_VERSION}/modules \
	-D OPENCV_GENERATE_PKGCONFIG=ON \
	-D BUILD_OPENCV_PYTHON2=OFF \
	-D WITH_CUDA=OFF \
	-D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
	-D BUILD_TESTS=OFF \
        -D INSTALL_TESTS=OFF \
        -D INSTALL_C_EXAMPLES=OFF \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D BUILD_EXAMPLES=OFF \
	-D OPENCV_ENABLE_NONFREE=ON \
	-D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
        ..

  if [[ $? == "0" ]];then 
    echo "cmake successfully!"
  else
    echo "cmake faild"
  fi
}

 install_opencv(){
  echo "start make and install"
  make -j$(nproc) && make install
  #cp -f ${BUILD_DIR}/unix-install/opencv4.pc /usr/lib/pkgconfig/
  local lib_path="${INSTALL_DIR}/lib/pkgconfig"
  
  echo "export  PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:${lib_path}" >> ~/.bashrc
  
  source ~/.bashrc
  ldconfig
  echo "======================================================================="  
}

 
 test_python_opencv(){
  python3 -c "import cv2 ; print('python-opencv version :' + cv2.__version__)"
 	
 }	

clean(){
  cd ${WORK_DIR}
  if [[ -d "${WORK_DIR}/opencv-${OPENCV_VERSION}" ]];then
	  rm -rf ${WORK_DIR}/opencv-${OPENCV_VERSION}
	  echo "del opencv"
  fi
  if [[ -d "${WORK_DIR}/opencv_contrib-${OPENCV_VERSION}" ]]; then
	  rm -rf ${WORK_DIR}/opencv_contrib-${OPENCV_VERSION}	
	  echo "del opencv_contrib"
  fi
  apt-get -qq autoremove && apt-get -qq clean
 
}

main(){
  echo "===============start install opencv===================================="
  if [[ -d ${WORK_DIR} ]];then
	  download
      if [[ $? == "0" ]];then
	    build
	  if [[ $? == "0" ]];then
	    install_opencv
	  fi
      fi
  fi
  clean
  test_python_opencv
 }


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
