configuration ActuatorC {
  provides interface Actuate<uint8_t>;
  uses {
    interface HplMsp430GeneralIO as OutPin;
  }
}
implementation {

  components ActuatorP;
  components Msp430TimerC, MainC;

  ActuatorP.Init <- MainC.SoftwareInit;
  ActuatorP.TimerCompare0 -> Msp430TimerC.Compare0_A0;

  ActuatorP.TimerControl1 -> Msp430TimerC.Control0_A1;
  ActuatorP.TimerCompare1 -> Msp430TimerC.Compare0_A1;

  ActuatorP.TimerControl2 -> Msp430TimerC.Control0_A3;
  ActuatorP.TimerCompare2 -> Msp430TimerC.Compare0_A3;

  ActuatorP.MspTimer -> Msp430TimerC.Timer0_A;

  /*ActuatorP.OutPin1 -> GPIO.Port46;*/
  /*ActuatorP.OutPin2 -> GPIO.Port47;*/
  ActuatorP.OutPin1 = OutPin1;
  ActuatorP.OutPin2 = OutPin2;

  Actuate = ActuatorP;

}
