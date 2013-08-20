configuration AngleControllerC {
  uses {
    interface Read<float>;
    interface Actuate<uint8_t>;
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
  components LedsC;
  components UserButtonC;

  AngleControllerP.Timer -> TimerMilliC;
  AngleControllerP.Leds -> LedsC;
  AngleControllerP.Notify -> UserButtonC;

  AngleControl = AngleControllerP;
  Read = AngleControllerP;
  Actuate = AngleControllerP;
  InclinometerControl = AngleControllerP;
  SplitControl = AngleControllerP;
}
