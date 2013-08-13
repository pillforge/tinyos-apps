configuration AngleControllerC {
  provides interface AngleControl;
  uses {
    interface Read<float>;
    interface Actuate;
  }
  
}
implementation {
  components AngleControllerP;
  components new TimerMilliC();
  AngleControllerP.Timer -> TimerMilliC;
  AngleControl = AngleControllerP;
  Read = AngleControllerP;
  Actuate = AngleControllerP;
}
