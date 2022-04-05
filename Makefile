
PROJ_NAME = STM32L152-EVAL_GPIO_IOToggle
DEVICE = stm32/device
CORE = stm32/core
PERIPH = stm32/periph
DISCOVERY = stm32/discovery
USB = stm32/usb

STM_ROOT         = /home/cyclops/project

# This is where the source files are located,
# which are not in the current directory
# (the sources of the standard peripheral library, which we use)
# see also "info:/make/Selective Search" in Konqueror

MY_SRC_DIR       = $(STM_ROOT)/$(PROJ_NAME)/src
STM_SRC_DIR      = $(STM_ROOT)/$(PROJ_NAME)/Libraries/STM32L1xx_StdPeriph_Driver/src
STM_STARTUP_DIR  = $(STM_ROOT)/$(PROJ_NAME)/startup
BUILDDIR         = $(STM_ROOT)/$(PROJ_NAME)/build



# SOURCES += $(DISCOVERY)/src/stm32f3_discovery.c

SOURCES += $(MY_SRC_DIR)/main.c \
		   $(MY_SRC_DIR)/stm32l1xx_it.c \
		   $(MY_SRC_DIR)/syscalls.c \
		   $(MY_SRC_DIR)/startup_stm32l1xx_md.s \
		   $(MY_SRC_DIR)/system_stm32l1xx.c \
		   $(MY_SRC_DIR)/tiny_printf.c \
		   $(MY_SRC_DIR)/rcc.c \
		   $(STM_SRC_DIR)/stm32l1xx_gpio.c \
		   $(STM_SRC_DIR)/stm32l1xx_rcc.c \
		   $(STM_SRC_DIR)/misc.c \
		   $(STM_SRC_DIR)/stm32l1xx_dac.c

#STARTUP =$(STM_STARTUP_DIR)/startup_stm32f334x8.s
STARTUP =$(STM_STARTUP_DIR)

#OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))
OBJECTS = $(addsuffix .o, $(basename $(SOURCES)))


#$(error   VAR is $(SOURCES))


# INC_DIR += -I$(DEVICE)/include \
			-I$(CORE)/include \
			-I$(PERIPH)/include \
			-I$(DISCOVERY)/include \
			-I$(USB)/include \
			-I\

# The header files we use are located here
INC_DIR += -I$(STM_ROOT)/$(PROJ_NAME)/Libraries/CMSIS/Device/ST/STM32L1xx/Include \
			-I$(STM_ROOT)/$(PROJ_NAME)/Libraries/CMSIS/Include \
			-I$(STM_ROOT)/$(PROJ_NAME)/Libraries/STM32L1xx_StdPeriph_Driver/inc \
			-I$(STM_ROOT)/$(PROJ_NAME)/Utilities/STM32_EVAL/STM32L152_EVAL \
			-I$(STM_ROOT)/$(PROJ_NAME)/Utilities/STM32_EVAL/Common \
			-I$(STM_ROOT)/$(PROJ_NAME)/inc \
			-Isrc \

# INC_DIR += -ILibraries/CMSIS/device/ST/STM32F30x/Include/ \
# 			-ILibraries/CMSIS/core/ \
# 			-ILibraries/StdPeriph_Driver/inc/ \
# 			-IUtilities/STM32F3_Discovery/ \
# 			-Iinc/ \
# 			-I/. \

#$(error   INCL is $(INC_DIRS))

ELF = $(BUILDDIR)/$(PROJ_NAME).elf
HEX = $(BUILDDIR)/$(PROJ_NAME).hex
BIN = $(BUILDDIR)/$(PROJ_NAME).bin

CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
AR = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy
AS = arm-none-eabi-as
SZ = arm-none-eabi-size
GDB = arm-none-eabi-gdb
GDBPY = arm-none-eabi-gdb-py

 	
CFLAGS  = -Og -g -Wall -I.\
   -mcpu=cortex-m3 -mthumb -mfloat-abi=soft \
   $(INC_DIR) -DUSE_STDPERIPH_DRIVER --specs=nosys.specs \
   -DUSE_STM32L152_EVAL -DUSE_DEFAULT_TIMEOUT_CALLBACK \
   -DSTM32L1XX_MD

LDSCRIPT = stm32_flash.ld
LDFLAGS += -T$(LDSCRIPT) -mthumb -mcpu=cortex-m3 -mfloat-abi=soft --specs=nosys.specs -DUSE_STM32L152_EVAL -DUSE_DEFAULT_TIMEOUT_CALLBACK -DSTM32L1XX_MD
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@
	$(SZ) $<

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(ELF): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

flash: $(BIN) $(HEX)
	st-flash write $(BIN) 0x8000000

# rflash: $(BIN) $(HEX)
# 	st-flash write $(BIN) 0x8000000

# iflash: $(BIN) $(HEX)
# 	st-flash write $(BIN) 0x8000000

gdb: $(ELF)
	$(GDBPY) $<

burn: $(HEX)
	openocd -f "/usr/share/openocd/scripts/board/stm32ldiscovery.cfg"

clean:
	rm -rf ./src/*.o
	rm -rf ./Libraries/STM32L1xx_StdPeriph_Driver/src/*.o
