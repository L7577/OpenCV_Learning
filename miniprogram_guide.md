


# 在微信小程序中使用opencv

opencv提供了网页版开发教程[OpenCV.js Tutorials](https://docs.opencv.org/5.x/d5/d10/tutorial_js_root.html)

在web开发中需要用到 opencv.js
可以直接下载编译好的文件[release](https://github.com/opencv/opencv/releases)，也可以自己编译[build opencv.js](https://docs.opencv.org/5.x/d4/da1/tutorial_js_setup.html)！


微信小程序开发需要重新编译生成 [WXWebAssembly](https://developers.weixin.qq.com/miniprogram/dev/framework/performance/wasm.html) 支持的wasm文件，也需要修改编译配置及部分函数用法！



需要的构建工具
- Emscripten
> [Emscripten](https://github.com/emscripten-core/emscripten) is an LLVM-to-JavaScript compiler. We will use Emscripten to build OpenCV.js.

-Docker(环境支持，使用emscripten镜像更方便)

-[brotli](https://github.com/google/brotli)压缩工具

---
## 使用docker编译opencv.js和opencv.wasm

下载对应版本的[opencv](https://github.com/opencv/opencv.git)源码


```
#下载源码
git clone https://github.com/opencv/opencv.git

#编译命令
docker run --rm -v $(pwd):/src -u $(id -u):$(id -g) emscripten/emsdk emcmake python3 ./platforms/js/build_js.py build_js --build_wasm --simd 
```

*可能出现的问题，直接pull的Emscripten镜像版本太新，编译过程中会出错*

**以下实验中会使用教程中的2.0.10版本**

再次检查
- 准备好opencv源码
- 下载好2.0.10版本的Emscripten镜像包

### 修改编译配置文件

#### 删除多余模块

**platforms/js/opencv_js.config.py**

```
white_list = makeWhiteList([core, imgproc, objdetect, video, dnn, features2d, photo, aruco, calib3d])

#可删掉不需要的模块

```

#### 输出独立的wasm文件

[Could not generate .wasm file when building opencv.js #13356
](https://github.com/opencv/opencv/issues/13356)

**modules/js/CMakeLists.txt**

```
#set(EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS} -s MODULARIZE=1 -s SINGLE_FILE=1")
set(EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS} -s MODULARIZE=1")

#删除 SINGLE_FILE=1 
```

#### 禁用动态执行函数

**modules/js/CMakeLists.txt**

```

set(EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS} -s DYNAMIC_EXECUTION=0")

#增加DYNAMIC_EXECUTION=0参数
```

查看编译参数

```
./platforms/js/build_js.py -h
```

开始编译

```
docker run --rm -v $(pwd):/src -u $(id -
u):$(id -g) emscripten/emsdk:2.0.10 emcmake python3 ./platform
s/js/build_js.py build_wasm --build_wasm
```

压缩

```
#在build_wasm/bin/目录下

-rw-rw-r-- 1 l l 3.6K 10月 17 14:53 loader.js
-rw-r--r-- 1 l l 165K 10月 17 14:53 opencv.js
-rw-r--r-- 1 l l 164K 10月 17 14:53 opencv_js.js
-rwxr-xr-x 1 l l 6.7M 10月 17 14:52 opencv_js.wasm*
drwxr-xr-x 2 l l 4.0K 10月 17 14:46 perf/

# 生成的wasm文件有6.7M，小程序单个包最大是2M，需要分解成多个包或者进行压缩！

# 使用brotli工具压缩

brotli -o build_wasm/bin/opencv_js.wasm.br build_wasm/bin/opencv_js.wasm


# 压缩后是1.5M
-rwxr-xr-x 1 l l 1.5M 10月 17 14:52 opencv_js.wasm.br*

```



### 微信开发者工具


[WXWebAssembly官方文档](https://developers.weixin.qq.com/miniprogram/dev/framework/performance/wasm.html)


在微信开发者工具中创建一个新项目

导入相关文件

#### 修改opencv.js文件
先使用编辑器格式化一下

官方教程：
[使用WXWebAssembly优化运算性能](https://developers.weixin.qq.com/community/business/doc/0000e8ba0f8818bbf3fd94b3d5680d)

修改参考代码
[6.6/go_stopwatch/wasm_exec.js](https://gitee.com/geektime-geekbang_admin/weapp_optimize/blob/master/6.6/go_stopwatch/wasm_exec.js)

[How to include cv.imread() when building opencv.js?](https://stackoverflow.com/questions/67190799/how-to-include-cv-imread-when-building-opencv-js)


```
# opencv.js

return cv.ready
#修改
return cv

```