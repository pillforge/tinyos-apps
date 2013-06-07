#include "printf.h"
configuration GpioTestAppC{
}
implementation {
  components GpioTestC, MainC, LedsC;
  components HplMsp430GeneralIOC as Pins;
  components new TimerMilliC() as Timer0;
  components SerialPrintfC;

  GpioTestC -> MainC.Boot;
  GpioTestC.Leds -> LedsC;
  GpioTestC.SensePin0-> Pins.Port70;
  GpioTestC.SensePin1-> Pins.Port71;
  GpioTestC.SensePin2-> Pins.Port72;
  GpioTestC.OutPin0-> Pins.Port42;
  GpioTestC.OutPin1-> Pins.Port41;
  GpioTestC.OutPin2-> Pins.Port43;
  GpioTestC.Timer -> Timer0;
}

