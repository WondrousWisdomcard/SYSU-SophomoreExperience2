OBJPREFIX	:= __objs_

.SECONDEXPANSION:
# -------------------- function begin --------------------

## 定义了一系列“快捷指令”（函数）来实现一些功能

## 说明：
	## -I gcc参数：首先在指定目录中寻找头文件
	## -M 生成依赖信息，包含标准头文件
	## -MM 生成依赖信息，忽略由标准头文件 #include <head.h> 造成的依赖
	## -MT 指定依赖目标
	## | 表示 order-only 依赖目标，第一次执行 make 时寻找并生成该依赖，生成后即使该依赖目标文件时间变化，也不更新目标。
	## $< 第一个依赖目标
	## $@ 第一个 target 目标
	## $^ 表示所有依赖文件
	
# list all files in some directories: (#directories, #types)
## 1. listf 列出指定目录下所有指定后缀的文件
listf = $(filter $(if $(2),$(addprefix %.,$(2)),%),\
		  $(wildcard $(addsuffix $(SLASH)*,$(1))))

# get .o obj files: (#files[, packet])
## 2. toobj 后缀替换成 .o ，参数 1 为文件列表，由空格隔开
toobj = $(addprefix $(OBJDIR)$(SLASH)$(if $(2),$(2)$(SLASH)),\
		$(addsuffix .o,$(basename $(1))))

# get .d dependency files: (#files[, packet])
## 3. todep 后缀替换成 .d，用法与 toobj 相同
todep = $(patsubst %.o,%.d,$(call toobj,$(1),$(2)))

## 4. totarget 添加 bin/ 前缀
totarget = $(addprefix $(BINDIR)$(SLASH),$(1))

# change $(name) to $(OBJPREFIX)$(name): (#names)
## 5. packetname 添加 __objs_ 前缀
packetname = $(if $(1),$(addprefix $(OBJPREFIX),$(1)),$(OBJPREFIX))

# cc compile template, generate rule for dep, obj: (file, cc[, flags, dir])
## 6. cc_template 指定编译模板
define cc_template
$$(call todep,$(1),$(4)): $(1) | $$$$(dir $$$$@)
	@$(2) -I$$(dir $(1)) $(3) -MM $$< -MT "$$(patsubst %.d,%.o,$$@) $$@"> $$@
$$(call toobj,$(1),$(4)): $(1) | $$$$(dir $$$$@)
	@echo + cc $$<
	$(V)$(2) -I$$(dir $(1)) $(3) -c $$< -o $$@
ALLOBJS += $$(call toobj,$(1),$(4))
endef


# compile file: (#files, cc[, flags, dir])
## 7. do_cc_compile 对参数 1 列出的每个文件分别按编译模板展开（cc_template）
define do_cc_compile
$$(foreach f,$(1),$$(eval $$(call cc_template,$$(f),$(2),$(3),$(4))))
endef

# add files to packet: (#files, cc[, flags, packet, dir])
## 8. do_add_files_to_packet 将参数1文件打包到指定Packet中
define do_add_files_to_packet
__temp_packet__ := $(call packetname,$(4))
ifeq ($$(origin $$(__temp_packet__)),undefined)
$$(__temp_packet__) :=
endif
__temp_objs__ := $(call toobj,$(1),$(5))
$$(foreach f,$(1),$$(eval $$(call cc_template,$$(f),$(2),$(3),$(5))))
$$(__temp_packet__) += $$(__temp_objs__)
endef

# add objs to packet: (#objs, packet)
## 9. add objs to packe 将参数1的obj文件打包到指定Packet中
define do_add_objs_to_packet
__temp_packet__ := $(call packetname,$(2))
ifeq ($$(origin $$(__temp_packet__)),undefined)
$$(__temp_packet__) :=
endif
$$(__temp_packet__) += $(1)
endef

# add packets and objs to target (target, #packes, #objs[, cc, flags])
## 10. do_create_target 向目标添加Packet和Obj文件
## 使用例子：$(eval $(call do_create_target,main,,obj/tmp/src/main.o obj/tmp/src/init.o obj/tmp/src/common.o,gcc,-g))
define do_create_target
__temp_target__ = $(call totarget,$(1))
__temp_objs__ = $$(foreach p,$(call packetname,$(2)),$$($$(p))) $(3)
TARGETS += $$(__temp_target__)
ifneq ($(4),)
$$(__temp_target__): $$(__temp_objs__) | $$$$(dir $$$$@)
	$(V)$(4) $(5) $$^ -o $$@
else
$$(__temp_target__): $$(__temp_objs__) | $$$$(dir $$$$@)
endif
endef

# finish all
## 11. do_finish_all 定义 ALLDEPS 变量为所有目标文件后缀.o替换成.d，并创建第一个目标所需的目录
define do_finish_all
ALLDEPS = $$(ALLOBJS:.o=.d)
$$(sort $$(dir $$(ALLOBJS)) $(BINDIR)$(SLASH) $(OBJDIR)$(SLASH)):
	@$(MKDIR) $$@
endef

# --------------------  function end  --------------------

## 对上述定义的函数进行封装

# 1. 对 do_cc_compile 的封装
	# @files 编译源文件
	# @cc 指定编译器
	# @flags 编译参数，如 -g
	# @dir 中间目录
	# Example: $(eval $(call cc_compile,main.c init.c common.c,gcc,-g,temp))
	# compile file: (#files, cc[, flags, dir])
cc_compile = $(eval $(call do_cc_compile,$(1),$(2),$(3),$(4)))


# 2.对 do_add_files_to_packet 的封装
	# @files 编译源文件
	# @cc 指定编译器
	# @flags 编译参数
	# @packet packet指定的项目前添加 OBJPREFIX 指定的字符前缀，包含多项时，每项通过空格分割
	# @dir 中间目录
	# Example: $(eval $(call do_add_files_to_packet,main.c init.c,gcc,-g,main init,temp))
	# add files to packet: (#files, cc[, flags, packet, dir])
add_files = $(eval $(call do_add_files_to_packet,$(1),$(2),$(3),$(4),$(5)))

# 3.对 do_add_objs_to_packet 的封装
	# @objs 目标文件
	# @packet 同 add_files 中的 packet
	# Example: $(eval $(call do_add_objs_to_packet,main.o init.o,main init))
	# add objs to packet: (#objs, packet)
add_objs = $(eval $(call do_add_objs_to_packet,$(1),$(2)))

# 4. 对 do_create_target 的封装
	# @target 最终目标
	# @packet 同 add_files 中的 packet
	# @obj 目标文件
	# @cc 编译器
	# @flags 编译选项
	# Example: $(eval $(call do_create_target,main,PACKET,main.o init.o common.o,gcc,-g))
	# add packets and objs to target (target, #packet, #objs, cc, [, flags])
create_target = $(eval $(call do_create_target,$(1),$(2),$(3),$(4),$(5)))

# 5. 对参数 1 指定的项目中的每一项添加 OBJPREFIX 指定的字符前缀，然后构成新的变量，输出新变量的值
read_packet = $(foreach p,$(call packetname,$(1)),$($(p)))

# 6. 参数 1 指定目标，参数 2 指定依赖
add_dependency = $(eval $(1): $(2))

# 7. 对 do_finish_all 的封装，定义 ALLDEPS 变量为所有目标文件后缀替换成 .d，并创建第一个目标所需的目录

## 部分参考博客：https://blog.csdn.net/Anhui_Chen/article/details/106892975

