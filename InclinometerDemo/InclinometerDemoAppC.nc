#include "InclinometerDemo.h"

configuration InclinometerDemoAppC{
}

implementation {
  components InclinometerDemoC, MainC;
  components AngleControllerC as Controller;
  components ActuatorC as Motor;
  /*components new DemoSensorC() as Accel;*/
  components new Msp430InternalTemperatureC() as Accel;
  components InclinometerC;
  components new SerialAMSenderC(AM_ACCELMSG), SerialActiveMessageC;

  InclinometerDemoC -> MainC.Boot;
  InclinometerDemoC.AngleControl -> Controller;
  InclinometerDemoC.SerialControl -> SerialActiveMessageC;
  InclinometerDemoC.SerialSend -> SerialAMSenderC;

  // Controller reads angles from the Inclinometer and controls the motor according to the set desired angle.
  Controller.Actuate -> Motor;
  Controller.Read -> InclinometerC;

  // Inclinometer reads from accelerometer and converts the data to inclination angle
  InclinometerC.AccelRead -> Accel;
  InclinometerDemoC.AccelRead -> Accel;

}
