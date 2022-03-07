# Learn Opencv

OpenCV官方网址 ：https://opencv.org/

Github :https://github.com/opencv/opencv

Docs:https://docs.opencv.org/4.5.5/d9/df8/tutorial_root.html

**Tutorials**:https://docs.opencv.org/4.5.5/d9/df8/tutorial_root.html



还未安装opencv？  [如何安装 opencv](./opencv_install_guide.md)

快速构建自己的Docker镜像

```sh
#下载仓库代码
https://github.com/L7577/OpenCV_learning.git

cd OpenCV_learning

#修改Makefile  
vim Makefile

#构建的镜像名称或者仓库名称
DOCKER_IMAGE	=opencv_test

#选择基础镜像包
BASE_IMAGE	=ubuntu:18.04

#修改镜像包标签版本
TAG_VERSION 	=$(BUILD_IMAGE_TYPE)-1.0.5

#选择是否开启CUDA ，需要提前安装好nvidia-driver 和 NVIDIA Container Toolkit，并且设置好 runtime为 nvidia
build:NVIDIA:=nvidia  #开启，默认关闭

#修改运行镜像时所需的参数
RUN_ARGS	=-it \
		 -v /home/l/test:/test
#运行时容器名称
CONTAINER_NAME	=test_1

#修改完Makefile，保存推出

#开始构建镜像
make  build

#上传镜像到仓库
make push

#运行容器,当前仅支持无CUDA版本使用该方式运行
make run 
```



