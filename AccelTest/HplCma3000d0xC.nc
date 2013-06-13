generic configuration HplCma3000d0xC() {
  provides {
    interface Read<accel_t> as Accel;
    interface Msp430UsciConfigure;
  }
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as AccelPower;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430GeneralIO as AccelInt;
  }
}
implementation {
  components new HplCma3000d0xP() as Cma;
  components new TimerMilliC() as TimerMs;
  components MainC;

  Accel = Cma;
  SpiByte = Cma;
  SpiResource = Cma;
  Msp430UsciConfigure = Cma;
  AccelPower = Cma.AccelPower;
  AccelCS = Cma.AccelCS;
  AccelInt = Cma.AccelInt;
  MainC.SoftwareInit -> Cma;
  Cma.TimerMs -> TimerMs;
}
