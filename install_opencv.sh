#!/bin/bash
#
# This bash script install opencv in ubuntu
#  
set -e
set -u
# if need debug this script , use set -x
#set -x
#set -o pipefail
# if use set -o pipefail , can't run with sh command and in Dockerfile RUN Command
#------------------------------
readonly ROOT=ON
# if don't need root,change it to OFF

#-------------------------------
# opencv with cuda
CUDA_SUPPORT=OFF

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

readonly INSTALL_DIR="/usr/local"
readonly OPENCV_VERSION=4.5.5

url_opencv="https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip"
url_opencv_contrib="https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip"

zip_opencv=opencv.zip
zip_opencv_contrib=opencv_contrib.zip



#-------------------------------

 command_exists(){
    command -v "$@" > /dev/null 2>&1
}

 need_help(){
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

 need_root(){
  if [[ "$1" == "ON" ]];then
      if [[ "$(id -un 2>/dev/null)" == "root" ]];then
           true
      else
           false
      fi
  elif [[ "$1" == "OFF" ]];then
      true 
  else 
      printf "The variable: ROOT in the script is set incorrectly, please check it\n" 
      exit 1 
  fi
}

#--------------------------------

download_files(){
  if command_exists wget ;then
     wget -qq $1 -O $2
     if command_exists unzip ;then
       unzip -qq $2 -d $3
     else
       printf "unzip not found,please check it \n"
     fi
  else
     printf "wget not found ,please check it \n"
     exit 1
  fi
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
  if command_exists cmake;then
     cmake ${cmake_options}
     printf "cmake ${cmake_options}\n"
  else
     printf "cmake not found,please check it \n"
     exit 1
  fi

  if command_exists make;then
     make -j$(nproc) && make install
     #cp -f ${BUILD_DIR}/unix-install/opencv4.pc /usr/lib/pkgconfig/opencv.pc
     local opencv_lib_path="${INSTALL_DIR}/lib/pkgconfig"
     echo "export  PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:${opencv_lib_path}" >> ~/.bashrc
     source ~/.bashrc
     ldconfig
  else 
     printf "make not found ,please check it \n"
     exit 1
  fi

}
 
 
test_python_opencv(){
 
   if command_exists python3 ; then
       python3 -c "import cv2 ; print('python-opencv version :' + cv2.__version__)"
   else
       printf "python not found,please check it\n"
       exit 1
   fi    
}	

check_files(){
while [[ "$#" > "0" ]] && [[ -n "$@" ]];
do
   if [[ -e $1 ]];then
      printf "remove $1\n"
      rm -rf $1
   else
      printf "$1 is not a directory or file ,please check it \n"
   fi
shift
done
}

install_test(){
local BUILD_DIR=${WORK_DIR}/opencv-${OPENCV_VERSION}/build

  if check_files $(ls -a| grep '^opencv*' 2>/dev/null) ;then
     
    download_files ${url_opencv} ${zip_opencv} ${WORK_DIR} && mkdir -p ${BUILD_DIR} && download_files ${url_opencv_contrib} ${zip_opencv_contrib} ${WORK_DIR}
    printf "download files is over! \n"
    if [[ "$?" == "0" ]] && [[ -d "${BUILD_DIR}" ]] ;then
      cd ${BUILD_DIR}
      printf "cmake options: ${cmake_options}\n"
      install_opencv 
    else
      printf "build directory not found ,please check it\n"
    fi
  else
    printf "Can't download files,please check!\n"
  fi

}


 main(){
  case "$1" in
	install) install_test ;;
	test) test_python_opencv;;
	help) need_help ; exit 1;;
	*)
	  printf "Usage: bash $0 [install] [test] [help] ... \n"	
          ;;
  esac
}

#-------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]];then
   if need_root $ROOT ;then
      if [[ "$#" != "0" ]];then
        main $@
      else
        printf " No input! \n Usage: bash $0 [install] [test] [help] ... \n"
      fi
   else
       printf " This bash script need root privileges. \n Please use root user or sudo command ! \n"
   fi
fi

