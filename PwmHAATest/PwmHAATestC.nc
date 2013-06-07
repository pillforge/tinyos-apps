module PwmHAATestC {
  provides {
    interface Init;
  }
  uses {
    interface HplMsp430GeneralIO;
    interface Msp430Compare as TimerCompare0;
    interface Msp430Compare as TimerCompare1;
    interface Msp430TimerControl as TimerControl0;
    interface Msp430TimerControl as TimerControl1;
    interface Msp430Timer as TimerB;
    interface Leds;
  }


}
implementation {

  uint16_t duty_cnt = 0x1;
  uint16_t duty_interm_cnt = 0;
  bool updown = TRUE;
  const uint16_t DUTY_MIN = 1;
  const uint16_t DUTY_MAX = 0x1ff;

  command error_t Init.init(){
    call TimerControl0.setControlAsCompare();
    call TimerControl0.enableEvents();
    call TimerControl1.setControlAsCompare();
    call TimerControl1.enableEvents();
    call TimerCompare0.setEvent(0x1ff);
    call TimerCompare1.setEvent(0x001);
    call TimerB.setClockSource(1);
    call TimerB.setMode(1);
    return SUCCESS;
  }

  async event void TimerCompare0.fired(){
    call Leds.led0On();
  }
  async event void TimerCompare1.fired(){
    call Leds.led0Off();
    if(duty_interm_cnt  < 1)
      duty_interm_cnt ++;
    else{
      duty_interm_cnt = 0;
      atomic{
        if(updown){
          duty_cnt+=20;
          if(duty_cnt >= 0x1d0){
            updown=FALSE;
          }
        }
        else{
          duty_cnt-=10;
          if(duty_cnt <= 10){
            updown=TRUE;
            duty_cnt=0;
          }
        }
      }
      call TimerCompare1.setEvent(duty_cnt);
    }
  }

  async event void TimerB.overflow(){
  }

}
