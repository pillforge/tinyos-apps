COMPONENT=DrugDeliveryBaseAppC
CFLAGS+=-I../include/ -I../DrugScheduler
BUILD_EXTRA_DEPS = ../PC/DrugSchedulerData.py
DrugSchedulerData.py: DrugScheduler.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=DrugSchedulerData DrugScheduler.h drug_scheduler -o
include $(MAKERULES)
