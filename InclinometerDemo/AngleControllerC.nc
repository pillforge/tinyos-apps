configuration AngleControllerC {
  uses {
    interface Read<float>;
    interface Actuate;
    interface SplitControl as InclinometerControl;
  }
  provides {
    interface SplitControl;
    interface AngleControl;
  }
  
}
implementation {
  components AngleControllerP;
  components new TimerMilliC();
  AngleControllerP.Timer -> TimerMilliC;
  AngleControl = AngleControllerP;
  Read = AngleControllerP;
  Actuate = AngleControllerP;
  InclinometerControl = AngleControllerP;
  SplitControl = AngleControllerP;
}
