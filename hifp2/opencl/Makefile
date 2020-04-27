# You must configure ALTERAOCLSDKROOT to point the root directory of the Intel(R) FPGA SDK for OpenCL(TM)
# software installation.
# See http://www.altera.com/literature/hb/opencl-sdk/aocl_getting_started.pdf 
# for more information on installing and configuring the Intel(R) FPGA SDK for OpenCL(TM).

ifeq ($(VERBOSE),1)
ECHO := 
else
ECHO := @
endif

# OpenCL compile and link flags.
AOCL_COMPILE_CONFIG := 
AOCL_LINK_CONFIG := 
U_NAME := $(shell uname)

# Compilation flags
ifeq ($(DEBUG),1)
CXXFLAGS += -g
else
CXXFLAGS += -O2
endif

# Compiler
CXX := g++

# Target
TARGET := host
TARGET_DIR := bin
FPID_DIR := fpid
REPORT_DIR := report

# Directories
INC_DIRS := ../common/inc
LIB_DIRS := 

# Files
INCS := $(wildcard )
SRCS := $(wildcard host/src/*.cpp ../common/src/AOCLUtils/*.cpp ../common/src/hifp/*.cpp ../common/src/utils/*.cpp)
LIBS :=
FRAMEWORKS := 

ifeq ($(U_NAME), Darwin)
FRAMEWORKS := OpenCL

else
# Where is the Intel(R) FPGA SDK for OpenCL(TM) software?
ifeq ($(wildcard $(ALTERAOCLSDKROOT)),)
$(error Set ALTERAOCLSDKROOT to the root directory of the Intel(R) FPGA SDK for OpenCL(TM) software installation)
endif
ifeq ($(wildcard $(ALTERAOCLSDKROOT)/host/include/CL/opencl.h),)
$(error Set ALTERAOCLSDKROOT to the root directory of the Intel(R) FPGA SDK for OpenCL(TM) software installation.)
endif

AOCL_COMPILE_CONFIG := $(shell aocl compile-config )
AOCL_LINK_CONFIG := $(shell aocl link-config )
LIBS := rt pthread

endif

# Make it all!
all : $(TARGET_DIR)/$(TARGET)

# Host executable target.
$(TARGET_DIR)/$(TARGET) : Makefile $(SRCS) $(INCS) $(TARGET_DIR) $(FPID_DIR) $(REPORT_DIR) clean
	$(ECHO)$(CXX) $(CPPFLAGS) $(CXXFLAGS) -fPIC $(foreach D,$(INC_DIRS),-I$D) \
		$(AOCL_COMPILE_CONFIG) $(SRCS) $(AOCL_LINK_CONFIG) \
		$(foreach D,$(LIB_DIRS),-L$D) \
		$(foreach L,$(LIBS),-l$L) \
		$(foreach L,$(FRAMEWORKS),-framework $L) \
		-o $(TARGET_DIR)/$(TARGET)

$(TARGET_DIR) :
	$(ECHO)mkdir $(TARGET_DIR) $(FPID_DIR) $(REPORT_DIR)
	
$(FPID_DIR) :
	$(ECHO)mkdir $(FPID_DIR)

$(REPORT_DIR) :
	$(ECHO)mkdir $(REPORT_DIR)

# Standard make targets
clean :
	$(ECHO)rm -f $(TARGET_DIR)/$(TARGET)

.PHONY : all clean
