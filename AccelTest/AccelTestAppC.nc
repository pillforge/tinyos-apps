#include "AccelTest.h"

configuration AccelTestAppC{
}
implementation {
  components AccelTestC, MainC;
  components new HplCma3000d0xC() as Cma3000;
  components new Msp430UsciSpiA0C() as Spi;
  components HplMsp430GeneralIOC as GPIO;
  components HplMsp430InterruptC as GPIO_Int;
  components LedsC, new TimerMilliC() as TimerLED;
  components new SerialAMSenderC(AM_ACCEL_MSG);

  components SerialActiveMessageC;

  AccelTestC -> MainC.Boot;
  AccelTestC.AccelSensor -> Cma3000;
  AccelTestC.AccelControl -> Cma3000;
  AccelTestC.Leds -> LedsC;
  AccelTestC.TimerLED -> TimerLED;
  AccelTestC.SerialSend -> SerialAMSenderC;
  AccelTestC.SerialControl -> SerialActiveMessageC;

  Cma3000.SpiByte -> Spi;
  Cma3000.SpiResource -> Spi;
  Cma3000 <- Spi.Msp430UsciConfigure;
  Cma3000.AccelPower -> GPIO.Port36;
  Cma3000.AccelCS -> GPIO.Port35;
  Cma3000.AccelInt -> GPIO_Int.Port25;
}
