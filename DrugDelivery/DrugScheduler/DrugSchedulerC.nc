configuration DrugSchedulerC {
  provides interface DrugSchedulerI;
} implementation {
  components DrugSchedulerP;
  DrugSchedulerI = DrugSchedulerP;

  components new AMReceiverC(AM_RADIODRUGSCHEDULERMSG);
  DrugSchedulerP.Receive -> AMReceiverC;
}
