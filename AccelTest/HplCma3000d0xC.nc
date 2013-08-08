generic configuration HplCma3000d0xC() {
  provides {
    interface Read<accel_t> as Accel;
    interface Msp430UsciConfigure;
    interface Init;
    interface SplitControl;
  }
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as AccelPower;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430Interrupt as AccelInt;
  }
}
implementation {
  components new HplCma3000d0xP() as Cma;
  components BusyWaitMicroC as BusyWait;
  components MainC, LedsC;

  Accel = Cma;
  SpiByte = Cma;
  SpiResource = Cma;
  Msp430UsciConfigure = Cma;
  Init = Cma;
  SplitControl = Cma;
  AccelPower = Cma.AccelPower;
  AccelCS = Cma.AccelCS;
  AccelInt = Cma.AccelInt;

  Cma.BusyWait -> BusyWait;
  Cma.Leds -> LedsC;
  Cma.Init <- MainC.SoftwareInit;
}
