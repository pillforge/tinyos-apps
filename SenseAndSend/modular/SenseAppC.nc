#include "SenseAndSend.h"

configuration SenseAppC {
  
}

implementation {

  components SenseC;
  components MainC;
  components new TimerMilliC() as Timer1;
  components Lsm330dlcC;

  SenseC.Boot -> MainC;
  SenseC.Timer -> Timer1;
  SenseC.AccelRead -> Lsm330dlcC.AccelRead;

}
