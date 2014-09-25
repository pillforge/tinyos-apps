generic configuration MotorDriverGenericC (uint8_t motor_id) {
  provides interface Actuate<uint8_t>;
}
implementation {

  components MotorMapC;
  components Msp430TimerC, MainC;
  components MotorDriverP;

  MotorDriverP.Init <- MainC.SoftwareInit;
  MotorDriverP.TimerCompare -> Msp430TimerC.Compare0_A0;
  MotorDriverP.MspTimer -> Msp430TimerC.Timer0_A;

  // Motors available
  components new ActuatorP() as Motor;

  Motor -> MotorMapC.Msp430Compare[motor_id];
  Motor -> MotorMapC.Msp430TimerControl[motor_id];
  Motor -> MotorMapC.HplMsp430GeneralIO[motor_id];

  MotorDriverP.SubInit -> Motor;
  Actuate = Motor;
}
