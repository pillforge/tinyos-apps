configuration PwmTestAppC{
}
implementation {
  components PwmTestC, MainC;
  components LedsC;
  components new TimerMilliC() as Timer0;
  components HplMsp430GeneralIOC as GPIO;

  PwmTestC -> MainC.Boot;
  PwmTestC.Leds -> LedsC;
  PwmTestC.Timer -> Timer0;
  PwmTestC.P1_2 -> GPIO.Port12;
  PwmTestC.P4_0 -> GPIO.Port40;
}
