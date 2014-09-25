configuration MotorDriverC {
  provides interface Actuate<uint8_t> as Actuate[uint8_t id];
}
implementation {

  components MotorMapC;
  components Msp430TimerC, MainC;
  components MotorDriverP;

  MotorDriverP.Init <- MainC.SoftwareInit;
  MotorDriverP.TimerCompare -> Msp430TimerC.Compare0_A0;
  MotorDriverP.MspTimer -> Msp430TimerC.Timer0_A;

  // Motors available
  components new ActuatorP() as A0,
             new ActuatorP() as A1,
             new ActuatorP() as A2,
             new ActuatorP() as A3;

  A0 -> MotorMapC.Msp430Compare[0];
  A0 -> MotorMapC.Msp430TimerControl[0];
  A0 -> MotorMapC.HplMsp430GeneralIO[0];

  A1 -> MotorMapC.Msp430Compare[1];
  A1 -> MotorMapC.Msp430TimerControl[1];
  A1 -> MotorMapC.HplMsp430GeneralIO[1];

  A2 -> MotorMapC.Msp430Compare[2];
  A2 -> MotorMapC.Msp430TimerControl[2];
  A2 -> MotorMapC.HplMsp430GeneralIO[2];

  A3 -> MotorMapC.Msp430Compare[3];
  A3 -> MotorMapC.Msp430TimerControl[3];
  A3 -> MotorMapC.HplMsp430GeneralIO[3];

  Actuate[0] = A0;
  Actuate[1] = A1;
  Actuate[2] = A2;
  Actuate[3] = A3;
  MotorDriverP.SubInit -> A0;
  /*MotorDriverP.SubInit -> A1;*/
  /*MotorDriverP.SubInit -> A2;*/
  /*MotorDriverP.SubInit -> A3;*/

}
