configuration RadioRXBlinkAppC{
}
implementation {
  components RadioRXBlinkC, MainC;
  components new TimerMilliC(), LedsC, ActiveMessageC;

  RadioRXBlinkC -> MainC.Boot;
  RadioRXBlinkC.Timer -> TimerMilliC;
  RadioRXBlinkC.Leds -> LedsC;
  RadioRXBlinkC.RadioControl -> ActiveMessageC.SplitControl;
  RadioRXBlinkC.Receive -> ActiveMessageC.Receive[240];
}
