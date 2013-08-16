generic configuration Lis331dlhC() {
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
  components new Lis331dlhP() as Lis331;
  components MainC;
  components new TimerMilliC() as Timer;

  Accel = Lis331;
  SpiByte = Lis331;
  SpiResource = Lis331;
  Msp430UsciConfigure = Lis331;
  Init = Lis331;
  SplitControl = Lis331;
  AccelCS = Lis331.AccelCS;


  Lis331.Init <- MainC.SoftwareInit;
  Lis331.Timer -> Timer;
}
