#include "InclinometerDemo.h"

configuration InclinometerDemoAppC{
}

implementation {
  components InclinometerDemoC, MainC;
  components AngleControllerC as Controller;
  components ActuatorC as Motor;
  /*components new DemoSensorC() as Accel;*/
  /*components new HplCma3000d0xC() as Accel;*/
  components new HplLis331dlhC() as Accel;
  components InclinometerC;
  components new SerialAMSenderC(AM_ACCELMSG), SerialActiveMessageC;
  /*components new TimerMilliC();*/

  InclinometerDemoC -> MainC.Boot;
  InclinometerDemoC.AngleControl -> Controller;
  InclinometerDemoC.AngleSplitControl -> Controller;
  InclinometerDemoC.SerialControl -> SerialActiveMessageC;
  InclinometerDemoC.SerialSend -> SerialAMSenderC;
  /*InclinometerDemoC.Timer -> TimerMilliC;*/

  // Controller reads angles from the Inclinometer and controls the motor according to the set desired angle.
  Controller.Actuate -> Motor;
  Controller.Read -> InclinometerC;
  Controller.InclinometerControl -> InclinometerC;

  // Inclinometer reads from accelerometer and converts the data to inclination angle
  InclinometerC.AccelControl -> Accel;
  InclinometerC.AccelRead -> Accel;
  InclinometerDemoC.AccelRead -> Accel;

  components new Msp430UsciSpiA0C() as Spi;
  /*components new Msp430UsciSpiB1C() as Spi;*/
  components HplMsp430GeneralIOC as GPIO;
  components HplMsp430InterruptC as GPIO_Int;

  Accel.SpiByte -> Spi;
  Accel.SpiResource -> Spi;
  Accel <- Spi.Msp430UsciConfigure;
  Accel.AccelPower -> GPIO.Port36;
  /*Accel.AccelCS -> GPIO.Port35;*/
  Accel.AccelCS -> GPIO.Port40;
  Accel.AccelInt -> GPIO_Int.Port25;
}
