ARG BASE_IMAGE

FROM ${BASE_IMAGE}  as base
WORKDIR /install
ARG PYTHON_VERSION
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update --fix-missing && apt-get -qq install -y \
	 --no-install-recommends  \
	build-essential g++ gcc cmake wget unzip pkg-config \
	libeigen3-dev libgtk-3-dev libqt4-dev libtbb-dev \
 	python3 python3-pip python3-numpy python3-dev	

FROM base as dev
COPY install_opencv.sh /install/install_opencv.sh
RUN bash /install/install_opencv.sh

