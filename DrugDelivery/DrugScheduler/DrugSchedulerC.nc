configuration DrugSchedulerC {
  provides interface DrugSchedulerI;
} implementation {
  components DrugSchedulerP;
  DrugSchedulerP = DrugSchedulerI;

  components new AMReceiverC(AM_RADIODRUGSCHEDULERMSG);
  DrugSchedulerP.Receive -> AMReceiverC;

  components new TimerMilliC() as Timer;
  DrugSchedulerP.Timer -> Timer;
}
