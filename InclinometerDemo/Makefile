COMPONENT=InclinometerDemoAppC
#CFLAGS+=-DLIS331_DEBUG
CFLAGS+=-DINCLINOMETER_DEBUG
BUILD_EXTRA_DEPS = InclinometerDemo.py Constants.py
CLEAN_EXTRA = InclinometerDemo.py Constants.py

InclinometerDemo.py: InclinometerDemo.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=InclinometerDemo InclinometerDemo.h AccelMsg  -o $@

Constants.py: Inclinometer.h
	ncg python -target=null -python-classname=Constants Inclinometer.h NORMALIZATION  -o $@

include $(MAKERULES)
