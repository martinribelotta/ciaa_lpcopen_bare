APP=freertos_blinky
#APP=lwip_freertos_tcpecho
#APP=lwip_freertos_webserver
#APP=lwip_tcpecho
#APP=lwip_webserver
#APP=misc_clock_apis
#APP=misc_iox_sensor
#APP=misc_lcd_helloworld
#APP=misc_otp_funcs
#APP=misc_pmc_states
#APP=misc_trimpot
#APP=periph_adc
#APP=periph_aes
#APP=periph_atimer
#APP=periph_blinky
#APP=periph_ccan
#APP=periph_dac
#APP=periph_dma_timertrig
#APP=periph_flashiap
#APP=periph_grouped_int
#APP=periph_i2c
#APP=periph_i2cm_interrupt
#APP=periph_i2cm_polling
#APP=periph_i2s
#APP=periph_pinint
#APP=periph_ritimer
#APP=periph_rtc
#APP=periph_sct_pwm
#APP=periph_sdio
#APP=periph_sdmmc
#APP=periph_ssp
#APP=periph_systick
#APP=periph_timers
#APP=periph_uart
#APP=periph_uart_rb
#APP=periph_watchdog
#APP=usbd_rom_bwtest
#APP=usbd_rom_cdc_uart
#APP=usbd_rom_cdc_vcom
#APP=usbd_rom_dfu_composite
#APP=usbd_rom_hid_generic
#APP=usbd_rom_hid_keyboard
#APP=usbd_rom_hid_mouse
#APP=usbd_rom_hid_sio
#APP=usbd_rom_libusb
#APP=usbd_rom_msc_ram
#APP=usbd_rom_msc_sdmmc

MODULES=lpc_chip_43xx lpc_board_ciaa_edu_4337
DEFINES=CORE_M4 __USE_LPCOPEN

TARGET=$(APP).elf
SRC=$(foreach m, $(MODULES), $(wildcard $(m)/src/*.c)) $(wildcard $(APP)/*/src/*.c)
INCLUDES=$(foreach m, $(MODULES), -I$(m)/inc) -Ilpc_chip_43xx/inc/usbd/ $(foreach i, $(wildcard $(APP)/*/inc), -I$(i))
_DEFINES=$(foreach m, $(DEFINES), -D$(m))
OBJECTS=$(SRC:.c=.o)
DEPS=$(SRC:.c=.d)
LDSCRIPT=ldscript/ciaa_lpc4337.ld

ARCH_FLAGS=-mcpu=cortex-m4 -mthumb
ARCH_FLAGS+=-mfloat-abi=hard -mfpu=fpv4-sp-d16

CFLAGS=$(ARCH_FLAGS) $(INCLUDES) $(_DEFINES) -ggdb3 -Og
LDFLAGS=$(ARCH_FLAGS) -T$(LDSCRIPT) -nostartfiles
LDFLAGS+=-Wl,-gc-sections
LDFLAGS+=$(foreach l, $(LIBS), -l$(l))

all: $(TARGET)

test_build_all:
	@rm logs/*.log
	@./logs/test_build_all.sh | tee logs/test_build_all.log

_:
	@echo $(CFLAGS)
	@echo $(LDFLAGS)

CROSS=arm-none-eabi-
CC=$(CROSS)gcc
LD=$(CROSS)gcc
SIZE=$(CROSS)size
OBJCOPY=$(CROSS)objcopy
LIST=$(CROSS)objdump -xCedlSwz
GDB=$(CROSS)gdb
OOCD=openocd

ifeq ("$(origin V)", "command line")
BUILD_VERBOSE=$(V)
endif
ifndef BUILD_VERBOSE
BUILD_VERBOSE = 0
endif
ifeq ($(BUILD_VERBOSE),0)
Q = @
else
Q =
endif


-include $(DEPS)

%.o: %.c
	@echo "CC $<"
	$(Q)$(CC) -MMD $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJECTS) Makefile
	@echo "LD $@"
	$(Q)$(LD) -o $@ $(OBJECTS) $(LDFLAGS)
	$(Q)$(OBJCOPY) -v -O binary $@ $(APP).bin
	$(Q)$(LIST) $@ > $(APP).lst
	$(Q)$(SIZE) $@

.PHONY: clean debug openocd

openocd:
	$(Q)$(OOCD) -f ciaa-nxp.cfg

debug: $(TARGET)
	$(Q)$(GDB) $< -ex "target remote :3333" -ex "mon reset halt" -ex "load" -ex "continue"

run: $(TARGET)
	$(Q)$(GDB) $< -batch -ex "target remote :3333" -ex "mon reset halt" -ex "load" -ex "mon reset run" -ex "quit"

download: $(TARGET)
	$(Q)$(OOCD) -f ciaa-nxp.cfg \
		-c "init" \
		-c "halt 0" \
		-c "flash write_image erase unlock $(APP).bin 0x1A000000 bin" \
		-c "reset run" \
		-c "shutdown"

erase:
	$(Q)$(OOCD) -f ciaa-nxp.cfg \
		-c "init" -c "halt 0" -c "flash erase_sector 0 0 last" -c "shutdown"

clean:
	@echo "CLEAN"
	$(Q)rm -fR $(OBJECTS) $(TARGET) $(APP).lst
