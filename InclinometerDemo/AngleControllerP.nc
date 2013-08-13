module AngleControllerP {
  provides interface AngleControl;
  uses {
    interface Read<float>;
    interface Timer<TMilli>;
    interface Actuate;
  }
  
}
implementation {
  uint8_t desiredAngle = 0;
  command error_t AngleControl.setAngle(uint8_t val){
    desiredAngle = val;
    call Timer.startPeriodic(10);
    return SUCCESS;
  }

  event void Timer.fired(){
    call Read.read();
  }

  event void Read.readDone(error_t error, float val){

  }
}

