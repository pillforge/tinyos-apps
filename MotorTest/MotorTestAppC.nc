configuration MotorTestAppC{
}
implementation {
  components MotorTestC, MainC, new TimerMilliC();
  components MotorDriverC as Motors;
  components HplMsp430GeneralIOC as GPIO;

  MotorTestC -> MainC.Boot;
  MotorTestC.M0 -> Motors.Actuate[0];
  MotorTestC.M1 -> Motors.Actuate[2];
  MotorTestC.Timer -> TimerMilliC;
}
