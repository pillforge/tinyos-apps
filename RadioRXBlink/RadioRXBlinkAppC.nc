configuration RadioRXBlinkAppC{
}
implementation {
  components RadioRXBlinkC, MainC;
  components new TimerMilliC(), LedsC, ActiveMessageC;
  components HplMsp430GeneralIOC as GpioC;
  components new TimerMilliC() as WatchdogTimerC;

  RadioRXBlinkC -> MainC.Boot;
  RadioRXBlinkC.Timer -> TimerMilliC;
  RadioRXBlinkC.Leds -> LedsC;
  RadioRXBlinkC.RadioControl -> ActiveMessageC.SplitControl;
  RadioRXBlinkC.Receive -> ActiveMessageC.Receive[6];
  RadioRXBlinkC.LowPowerListening -> ActiveMessageC;
  RadioRXBlinkC.DebugPin -> GpioC.Port21;
  RadioRXBlinkC.DebugPin2 -> GpioC.Port41;
  /*RadioRXBlinkC.DebugPin -> GpioC.Port80;*/
  RadioRXBlinkC.WatchdogTimer -> WatchdogTimerC;
}
