module MotorTestC {
  uses {
    interface Boot;
    interface Actuate<uint8_t> as M0;
    interface Actuate<uint8_t> as M1;
    interface Timer<TMilli>;
  }


}
implementation {
  enum {
    STATE_STOP,
    STATE_FWD,
    STATE_FWD_STOP,
    STATE_REV
  };

  int state = STATE_STOP;
  event void Boot.booted(){
    /*call Actuate.write(50);*/
    call Timer.startPeriodic(1000);
  }

  event void Timer.fired(){
    switch(state){
      case STATE_STOP:
        state = STATE_FWD;
        call M0.write(0);
        call M1.write(0);
        break;
      case STATE_FWD:
        state = STATE_FWD_STOP;
        call M0.write(50);
        break;
      case STATE_FWD_STOP:
        state = STATE_REV;
        call M0.write(0);
        break;
      case STATE_REV:
        state = STATE_STOP;
        call M1.write(50);
        break;
    }
  }

}
