
configuration TimerTestAppC{
}
implementation {
  components TimerTestC, MainC, LedsC;
  components new TimerMilliC() as Timer0;
  components HplMsp430GeneralIOC as Pins;

  TimerTestC -> MainC.Boot;
  TimerTestC.Timer -> Timer0;
  TimerTestC.Leds -> LedsC;
  TimerTestC.DebugPin -> Pins.Port70;
}

