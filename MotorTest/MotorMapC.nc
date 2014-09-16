configuration MotorMapC {
  provides {
    interface HplMsp430GeneralIO [uint8_t id];
    interface Msp430TimerControl[ uint8_t id ];
    interface Msp430Compare[ uint8_t id ];
  }
}
implementation {
  components Msp430TimerC;
  components HplMsp430GeneralIOC as GPIO;


  HplMsp430GeneralIO[0] = GPIO.Port12;
  Msp430TimerControl[0] = Msp430TimerC.Control0_A1;
  Msp430Compare[0] = Msp430TimerC.Compare0_A1;

  HplMsp430GeneralIO[1] = GPIO.Port13;
  Msp430TimerControl[1] = Msp430TimerC.Control0_A2;
  Msp430Compare[1] = Msp430TimerC.Compare0_A2;

  HplMsp430GeneralIO[2] = GPIO.Port14;
  Msp430TimerControl[2] = Msp430TimerC.Control0_A3;
  Msp430Compare[2] = Msp430TimerC.Compare0_A3;

  HplMsp430GeneralIO[3] = GPIO.Port15;
  Msp430TimerControl[3] = Msp430TimerC.Control0_A4;
  Msp430Compare[3] = Msp430TimerC.Compare0_A4;
}
