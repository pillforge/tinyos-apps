#include "Lis331dlh.h"
generic configuration HplLis331dlhC() {
  provides {
    interface Read<int16_t> as Accel;
    interface Msp430UsciConfigure;
    interface Init;
    interface SplitControl;
  }
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430GeneralIO as AccelPower;
    interface HplMsp430Interrupt as AccelInt;
  }
}
implementation {
  components new HplLis331dlhP() as Lis331;
  components MainC;
  components new TimerMilliC() as Timer;

  Accel = Lis331;
  SpiByte = Lis331;
  SpiResource = Lis331;
  Msp430UsciConfigure = Lis331;
  Init = Lis331;
  SplitControl = Lis331;
  AccelCS = Lis331.AccelCS;
  AccelPower = Lis331.AccelPower;
  AccelInt = Lis331.AccelInt;

  Lis331.Init <- MainC.SoftwareInit;
  Lis331.Timer -> Timer;
#ifdef LIS331_DEBUG
  components DiagMsgC;
  Lis331.DiagMsg -> DiagMsgC;
#endif
}
