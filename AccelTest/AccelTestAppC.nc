#include "printf.h"

configuration AccelTestAppC{
}
implementation {
  components AccelTestC, MainC;
  components new HplCma3000d0xC() as Cma3000;
  components new Msp430UsciSpiA0C() as Spi;
  components HplMsp430GeneralIOC as GPIO;
  components SerialPrintfC, LedsC, new TimerMilliC() as TimerLED;

  AccelTestC -> MainC.Boot;
  AccelTestC.AccelSensor -> Cma3000;
  AccelTestC.AccelControl -> Cma3000;
  AccelTestC.AccelInit -> Cma3000;
  AccelTestC.Leds -> LedsC;
  AccelTestC.TimerLED -> TimerLED;

  Cma3000.SpiByte -> Spi;
  Cma3000.SpiResource -> Spi;
  Cma3000 <- Spi.Msp430UsciConfigure;
  Cma3000.AccelPower -> GPIO.Port36;
  Cma3000.AccelCS -> GPIO.Port35;
  Cma3000.AccelInt -> GPIO.Port25;
}
