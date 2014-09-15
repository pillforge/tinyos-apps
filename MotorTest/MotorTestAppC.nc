configuration MotorTestAppC{
}
implementation {
  components MotorTestC, MainC, ActuatorC, new TimerMilliC();
  components HplMsp430GeneralIOC as GPIO;

  MotorTestC -> MainC.Boot;
  MotorTestC -> ActuatorC.Actuate;
  MotorTestC.Timer -> TimerMilliC;
  ActuatorC.OutPin1 -> GPIO.Port12;
  ActuatorC.OutPin2 -> GPIO.Port14;
}
