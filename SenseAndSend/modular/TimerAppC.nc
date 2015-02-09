configuration TimerCApp {
  
}

implementation {

  components TimerC;
  components MainC;
  components new TimerMilliC() as Timer1;
  TimerC.Boot -> MainC;
  TimerC.Timer -> Timer1;

}
