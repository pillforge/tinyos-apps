module MotorTestC {
  uses {
    interface Boot;
    interface Actuate<uint8_t>;
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
    /*call Actuate.write(50,FALSE);*/
    call Timer.startPeriodic(2000);
  }

  event void Timer.fired(){
    switch(state){
      case STATE_STOP:
        state = STATE_FWD;
        call Actuate.write(0,TRUE);
        break;
      case STATE_FWD:
        state = STATE_FWD_STOP;
        call Actuate.write(50,TRUE);
        break;
      case STATE_FWD_STOP:
        state = STATE_REV;
        call Actuate.write(0,TRUE);
        break;
      case STATE_REV:
        state = STATE_STOP;
        call Actuate.write(50,FALSE);
        break;
    }
  }

}
