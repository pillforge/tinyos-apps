configuration ClockTestAppC{
}
implementation {
  components ClockTestC, MainC;
  components HplMsp430GeneralIOC as GPIO;
  components new TimerMilliC(), LedsC;

  ClockTestC -> MainC.Boot;
  ClockTestC.SmclkOut -> GPIO.SMCLK;
  ClockTestC.MclkOut -> GPIO.MCLK;
  ClockTestC.AclkOut -> GPIO.ACLK;
  ClockTestC.Timer0 -> TimerMilliC;
  ClockTestC.Leds -> LedsC;

}
