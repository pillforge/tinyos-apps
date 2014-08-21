COMPONENT=AccelTestAppC
#CFLAGS=-DNEW_PRINTF_SEMANTICS
BUILD_EXTRA_DEPS = AccelTest.py
CLEAN_EXTRA = AccelTest.py

AccelTest.py: AccelTest.h cma3000-d0x.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=AccelTest AccelTest.h accel_msg  -o $@
include $(MAKERULES)
