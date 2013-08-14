module AngleControllerP {
  uses {
    interface Read<float>;
    interface Timer<TMilli>;
    interface Actuate;
    interface SplitControl as InclinometerControl;
  }
  
  provides {
    interface SplitControl;
    interface AngleControl;
  }
}
implementation {
  uint8_t desiredAngle = 0;
  command error_t SplitControl.start(){
    return call InclinometerControl.start();
  }
  command error_t SplitControl.stop(){
    return call InclinometerControl.stop();
  }

  event void InclinometerControl.startDone(error_t error){
    signal SplitControl.startDone(error);
  }
  event void InclinometerControl.stopDone(error_t error){
    signal SplitControl.stopDone(error);
  }

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

