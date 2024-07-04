KDIR:= /lib/modules/$(shell uname -r)/build
PWD:= $(shell pwd)
obj-m:= sdma.o

sdma-objs := sdma_drv.o sdma_hw.o

all: sdma_drv.c sdma_hw.c sdma.h
	$(MAKE) -C $(KDIR) M=$(PWD) modules
install: 
	sudo rmmod sdma
	sudo insmod sdma.ko
clean:
	rm main modules.* Module.* *.mod *.o *.ko *.mod.c .sdma* 2> /dev/null