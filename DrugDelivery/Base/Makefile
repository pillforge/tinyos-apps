COMPONENT=DrugDeliveryBaseAppC
CFLAGS+=-I../include/ -I../DrugScheduler
BUILD_EXTRA_DEPS = DrugSchedulerMsg.py
DrugSchedulerMsg.py: ../DrugScheduler/DrugScheduler.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=DrugSchedulerMsg ../DrugScheduler/DrugScheduler.h DrugSchedulerData -o DrugSchedulerMsg.py
include $(MAKERULES)
