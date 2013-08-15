module AngleControllerP {
  uses {
    interface Read<float>;
    interface Timer<TMilli>;
    interface Actuate<uint8_t>;
    interface SplitControl as InclinometerControl;
  }

  provides {
    interface SplitControl;
    interface AngleControl;
  }
}
implementation {
  float desiredAngle = 0;
  float current_angle = 0;
  const float Kp = 15.0;
  const float Kd = 1.0;

  float angle_error, angle_error_last;

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
    desiredAngle = (float)val;
    call Timer.startPeriodic(10);
    return SUCCESS;
  }

  event void Timer.fired(){
    call Read.read();
  }

  task void controller_task(){
    float pid_error;
    bool dir;
    atomic angle_error = desiredAngle - current_angle;

    if(fabs(angle_error) < 3){
      signal AngleControl.setAngleDone(SUCCESS);
    }
    pid_error = Kp*angle_error + Kd*(angle_error - angle_error_last);
    angle_error_last = angle_error;
    dir = (pid_error >= 0);
    pid_error = fabs(pid_error);

    if(pid_error > 255.0)
      pid_error = 255.0;

    call Actuate.write((uint8_t)pid_error, dir);
  }
  // Main PID algorithm
  event void Read.readDone(error_t error, float val){
    if(error == SUCCESS){
      current_angle = val;
      post controller_task();
    }
  }
}

