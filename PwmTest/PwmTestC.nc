module PwmTestC {
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli>;
    interface HplMsp430GeneralIO as P1_2;
    interface HplMsp430GeneralIO as P4_0;
  }


}
implementation {

  uint16_t duty_cnt = 0;
  uint16_t duty_interm_cnt = 0;
  bool updown = TRUE;
  const uint16_t DUTY_MIN = 100;
  const uint16_t DUTY_MAX = 0xf9b;

  event void Boot.booted(){
    call Timer.startPeriodic(1);
    TB0CCTL1 = BIT5 | BIT6;
    /*TA0CCTL1 = BIT7;*/
    /*TB0CCTL1 = BIT7;*/
    /*TA0CCTL1 = BIT7 | BIT6 | BIT5;*/
    /*TA0CCTL1 = BIT0;*/
    TB0CCR0 = 0xfff;
    TB0CCR1 = 0x7ff;
    TB0CTL = BIT4 | BIT8; 
    call P1_2.selectModuleFunc();
    call P1_2.makeOutput();
    call P4_0.selectModuleFunc();
    call P4_0.makeOutput();
  }

  event void Timer.fired(){
    uint16_t tval = TB0R;
    call Leds.set(tval >> 12);
    if(duty_interm_cnt == 0){
      if(updown){
        if(duty_cnt++ >= DUTY_MAX){
          updown = FALSE;
        }
      }else{
        if(duty_cnt-- == DUTY_MIN){
          updown = TRUE;
        }
      }
      TB0CCR1 = duty_cnt;
    }
    if(duty_interm_cnt++ > 10) duty_interm_cnt = 0;
    /*if ((tval >> 13) & 1)*/
    /*  TA0CCTL1 |= BIT2;*/
    /*else*/
    /*  TA0CCTL1 &= ~BIT2;*/
  }

}
