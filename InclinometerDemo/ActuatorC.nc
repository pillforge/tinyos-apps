configuration ActuatorC {
  provides interface Actuate<uint8_t>;
}
implementation {

  components ActuatorP;
  components Msp430TimerC, MainC;
  components HplMsp430GeneralIOC as GPIO;

  ActuatorP.Init <- MainC.SoftwareInit;
  ActuatorP.TimerCompare0 -> Msp430TimerC.Compare0_B0;

  ActuatorP.TimerControl1 -> Msp430TimerC.Control0_B2;
  ActuatorP.TimerCompare1 -> Msp430TimerC.Compare0_B2;

  ActuatorP.TimerControl2 -> Msp430TimerC.Control0_B3;
  ActuatorP.TimerCompare2 -> Msp430TimerC.Compare0_B3;

  ActuatorP.TimerB -> Msp430TimerC.Timer0_B;

  ActuatorP.OutPin1 -> GPIO.Port46;
  ActuatorP.OutPin2 -> GPIO.Port47;

  Actuate = ActuatorP;

}
