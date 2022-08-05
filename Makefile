cpp_srcs := $(shell find src -name "*.cpp")
cpp_objs := $(patsubst %.cpp,%.o,$(cpp_srcs))
cpp_objs := $(subst src/,objs/,$(cpp_objs))

cu_srcs := $(shell find src -name "*.cu")
cu_objs := $(patsubst %.cu,%.cuo,$(cu_srcs))
cu_objs := $(subst src/,objs/,$(cu_objs))

# 定义名称参数
workspace := workspace
binary := pro

# 定义头文件 库文件 和链接目标
include_paths := /usr/local/cuda/include
include_paths += src
include_paths += /usr/local/include/eigen3


library_paths := /usr/local/cuda/lib64
link_librarys := cudart

# 定义编译选项
cpp_compile_flags := -m64 -fPIC -g -O0 -std=c++11  -lrealsense2 -lstdc++fs
cu_compile_flags := -m64 -g -O0 -std=c++11

# 对头文件 库文件 和链接目标统一加-I -L -l
# -L 指定链接目标时查找的目录
# -l 指定链接的目标名称， 符合libname.so, -lname 规则
# -I 指定编译时头文件查找目录
rpaths 		  := $(foreach item,$(link_librarys),-Wl,-rpath=$(item))
include_paths := $(foreach item,$(include_paths),-I$(item))
library_paths := $(foreach item,$(library_paths),-L$(item))
link_librarys := $(foreach item,$(link_librarys),-l$(item))

# 合并选项
cpp_compile_flags += $(include_paths)
cu_compile_flags  += $(include_paths)
link_flags        := $(rpaths) $(library_paths) $(link_librarys)

# 定义cpp的编译方式
# $@  生成项
# $<  依赖项第一个
# $^  依赖项所有
# $?  $+

objs/%.o : src/%.cpp
	@mkdir -p $(dir $@)
	@echo Compile $<
	@g++ -c $< -o $@ $(cpp_compile_flags)

# 定义cuda文件的编译方式
objs/%.cuo : src/%.cu
	@mkdir -p $(dir $@)
	@echo Compile $<
	@nvcc -c $< -o $@ $(cu_compile_flags)


# 定义workspace/pro文件的编译
$(workspace)/$(binary) : $(cpp_objs) $(cu_objs)
	@mkdir -p $(dir $@)
	@echo Link $@
	@g++ $^ -o $@ $(link_flags) -DNDEBUG

# 定义pro快捷编译指令,这里只发生编译，不执行
pro : $(workspace)/$(binary)

# 定义编译并执行的指令， 并且执行目录切换到workspace下
run : pro
	@cd $(workspace) && ./$(binary)

debug : 
	@echo $(cpp_objs)
	@echo $(cu_objs)

clear : 
	@rm -rf objs $(workspace)/$(binary)

# 指定伪标签，作为指令
.PHONY : clean debug run pro


