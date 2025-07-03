include ../Makefile.common

TI_DIR := ../ti-c6000-toolchain/c6000_7.4.24
TI_INC_DIR := $(TI_DIR)/include
TI_BIN_DIR := $(TI_DIR)/bin

PROTOBUF_C_DIR := ../protobuf-c
PROTOBUF_C_INC := $(PROTOBUF_C_DIR)

SRC_DIR := ./protobuf-c-text
INC_DIR := ./build-aux
BUILD_DIR := ./build
ASM_DIR := $(BUILD_DIR)/asm
LST_DIR := $(BUILD_DIR)/lst
LIB_DIR := ./lib

INCLUDES += $(TI_INC_DIR) $(INC_DIR) $(PROTOBUF_C_INC)

LIB = libprotobuf-c-text.lib
PROTOBUF_TEXT_LIB = $(LIB_DIR)/$(LIB)

OBJECTS := $(BUILD_DIR)/parse.obj

CC := $(TI_BIN_DIR)/cl6x
AR := $(TI_BIN_DIR)/ar6x

.PHONY: all clean

all:
	@make --silent -j"$(shell nproc)" $(PROTOBUF_TEXT_LIB)

objects: $(OBJECTS)

clean:
	@rm -rf "$(BUILD_DIR)" "$(PROTOBUF_TEXT_LIB)"

$(SRC_DIR)/parse.c: $(SRC_DIR)/parse.re
	@echo "Generating $@ from $<..."
	@re2c -s -o $@ $<

$(BUILD_DIR)/%.obj: $(SRC_DIR)/%.c
	@echo "Building $@ from $<..."
	@mkdir -p "$(dir $@)"
	@mkdir -p "$(ASM_DIR)"
	@mkdir -p "$(LST_DIR)"
	@$(CC) -k -q -al -as --mem_model:data=far "$<" $(CFLAGS) -fr"$(dir $@)" -fs"$(ASM_DIR)" -ff"$(LST_DIR)" -fb"$(LST_DIR)"

$(PROTOBUF_TEXT_LIB): $(OBJECTS)
	@echo "Building $@ from $<..."
	@mkdir -p "$(dir $@)"
	@$(AR) rs $@ $<


