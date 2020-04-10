# OpenCL compile and link flags.
AOCL_COMPILE_CONFIG := 
AOCL_LINK_CONFIG := 

U_NAME := $(shell uname)

# Compiler
CXX := g++

# Compilation flags
CXXFLAGS += -O2

# Target
TARGET := host
TARGET_DIR := bin

# Files
SRCS := $(wildcard ./*.cpp)
LIBS := 
FRAMEWORKS := 

ifeq ($(U_NAME),Darwin)
CXX := g++
FRAMEWORKS := OpenCL
else
AOCL_COMPILE_CONFIG := $(shell aocl compile-config)
AOCL_LINK_CONFIG := $(shell aocl link-config)
endif

# Make it all!
all : $(TARGET_DIR)/$(TARGET)

# Host executable target.
$(TARGET_DIR)/$(TARGET) : Makefile $(SRCS) $(TARGET_DIR)
	$(CXX) $(CXXFLAGS) -fPIC \
		$(AOCL_COMPILE_CONFIG) $(SRCS) $(AOCL_LINK_CONFIG) \
		$(foreach L,$(LIBS),-l$L) \
		$(foreach L,$(FRAMEWORKS),-framework $L) \
		-o $(TARGET_DIR)/$(TARGET)

$(TARGET_DIR) :
	mkdir $(TARGET_DIR)
	
# Standard make targets
clean :
	rm -f $(TARGET_DIR)/$(TARGET)

.PHONY : all clean
