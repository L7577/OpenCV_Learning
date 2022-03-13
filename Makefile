DOCKER_REGISTRY	=docker.io
DOCKER_ORG	=$(shell docker info 2>/dev/null | sed '/Username:/!d;s/.* //')
#image name or repository name 
DOCKER_IMAGE	=opencv_test
DOCKER_FULL_NAME=$(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(DOCKER_IMAGE)

ifeq ("$(DOCKER_ORG)","")
$(warning WARNING: No docker user found using results from whoami)
DOCKER_ORG	=$(shell whoami)
endif

DOCKER_RUNTIME =$(shell docker info 2>/dev/null | sed '/Runtime:/!d;s/.* //')
#runtimes?=nvidia
ifeq ("$(DOCKER_RUNTIME)","nvidia")
CUDA_VERSION    =cuda:10.0
CUDNN_VERSION   =cudnn7
NVIDIA_IMAGE_TYPE=devel
SYSTEM_NAME     =ubuntu18.04
NVIDIA		=nvidia
else
NVIDIA		=$(empty)
endif

BASE_IMAGE	=ubuntu:18.04

#runtime /  base / devel
BUILD_IMAGE_TYPE =devel

define build_image_name
$(if $(1),$(1)/$(CUDA_VERSION)-$(CUDNN_VERSION)-$(NVIDIA_IMAGE_TYPE)-$(SYSTEM_NAME),$(BASE_IMAGE))
endef

IMAGE_NAME =$(call build_image_name,$(NVIDIA))

PYTHON_VERSION	=3.6

#base or dev 
BUILD_TYPE	=dev
BUILD_PROGRESS	=auto
BUILD_ARGS	=--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) 
EXTRA_DOCKER_BUILD_FLAGS?=

#BUILD_CMD
BUILD		:=docker build
DOCKER_BUILD	=DOCKER_BUILDIT=1 \
		 $(BUILD) --progress=$(BUILD_PROGRESS) \
		 $(EXTRA_DOCKER_BUILD_FLAGS) \
		 --target $(BUILD_TYPE) \
		 -t $(DOCKER_FULL_NAME):$(TAG_VERSION) \
		 $(BUILD_ARGS) .

#PUSH_CMD
DOCKER_TAG	=latest
PUSH		:=docker push
DOCKER_PUSH	=$(PUSH) $(DOCKER_FULL_NAME):$(DOCKER_TAG)

#RM_CMD
RMI		:=-docker rmi -f
RM_IMAGE	=$(shell docker images -q $(DOCKER_ORG)/$(DOCKER_IMAGE):$(TAG_VERSION))

DOCKER_RMI	=$(RMI) $(RM_IMAGE)

#TAG_CMD
TAG		:=docker tag
#1.0.0 +
TAG_VERSION 	=$(BUILD_IMAGE_TYPE)-1.0.6
TAGS		=$(TAG) $(DOCKER_FULL_NAME):$(TAG_VERSION) $(DOCKER_FULL_NAME):$(DOCKER_TAG)


#RUN_CMD
RUN		:=docker run
RUN_IMAGE	=$(DOCKER_FULL_NAME):$(DOCKER_TAG)

RUN_ARGS	=-it \
		 -v /home/l/test:/test
CONTAINER_NAME	=test_1
DOCKER_RUN	=$(RUN) --name=$(CONTAINER_NAME) \
		 $(RUN_ARGS) \
		 $(RUN_IMAGE)
#-----------------------------------------------------------------------
COPY	:= cp
MKDIR	:= mkdir -p
MV	:= mv
RM	:= rm -f
AWK	:= sed
SH	:= sh
TOUCH	:= touch -c
PWD	:= PWD


#-----------------------------------------------------------------------

.PHONY:all
all: build push


.PHONY:build
build:NVIDIA=nvidia
build:BASE_IMAGE:=$(IMAGE_NAME)
build:
	@echo "-----------------strart build image -------------"
	@echo "BUILD_CMD: \n	$(DOCKER_BUILD)"
	@echo "TAG_CMD: \n	$(TAGS)"
	$(DOCKER_BUILD)
	$(TAGS)
	@echo "-------------------------------------------------\n"
.PHONY:push
push:BASE_IMAGE:=$(IMAGE_NAME)
push:
	@echo "----------------start push ----------------------"
	@echo "PUSH_CMD: \n$(DOCKER_PUSH)"
	$(DOCKER_PUSH)
	@echo "-------------------------------------------------\n"


.PHONY:run
run:
	@echo "------------------run ----------------------------"
	@echo "RUN_CMD: \n $(DOCKER_RUN)"
	$(DOCKER_RUN)
	@echo "--------------------------------------------------\n"

.PHONY:clean
clean:
	@echo "RMI_CMD: \n$(DOCKER_RMI)"
	$(DOCKER_RMI)
