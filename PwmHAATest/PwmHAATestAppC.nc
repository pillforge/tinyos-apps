configuration PwmHAATestAppC{
}
implementation {
  components PwmHAATestC, MainC;
  components HplMsp430GeneralIOC as GPIO;
  components Msp430TimerC;
  components LedsC;

  MainC.SoftwareInit -> PwmHAATestC;
  /*PwmHAATestC.P4_0 -> GPIO.Port40;*/
  PwmHAATestC.TimerControl0 -> Msp430TimerC.Control0_B0;
  PwmHAATestC.TimerCompare0 -> Msp430TimerC.Compare0_B0;

  PwmHAATestC.TimerControl1 -> Msp430TimerC.Control0_B1;
  PwmHAATestC.TimerCompare1 -> Msp430TimerC.Compare0_B1;

  PwmHAATestC.TimerB -> Msp430TimerC.Timer0_B;
  PwmHAATestC.Leds -> LedsC;
}
