generic configuration lis331dlh_C() {
  provides {
    interface Read<accel_t> as Accel;
    interface Msp430UsciConfigure;
    interface Init;
    interface SplitControl;
  }
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as AccelCS;
  }
}
implementation {
  components new lis331dlh_P() as Cma;
  components BusyWaitMicroC as BusyWait;
  components MainC;
  //components new TimerMilliC() as Timer0; 

  Accel = Cma;
  SpiByte = Cma;
  SpiResource = Cma;
  Msp430UsciConfigure = Cma;
  Init = Cma;
  SplitControl = Cma;
  AccelCS = Cma.AccelCS;
  

  Cma.BusyWait -> BusyWait;
  Cma.Init <- MainC.SoftwareInit;
//  Cma.Timer0 -> Timer0;
}
