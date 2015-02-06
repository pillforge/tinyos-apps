#include "SenseAndSend.h"

configuration SenseAndSendAppC {
  
}

implementation {

  components SenseC;
  components MainC;
  components new TimerMilliC() as Timer1;
  components Lsm330dlcC;

  SenseC.Boot -> MainC;
  SenseC.Timer -> Timer1;
  SenseC.AccelRead -> Lsm330dlcC.AccelRead;

  components SendC;
  components ActiveMessageC;
  components new AMSenderC(AM_SENSORDATAMSG);

  SendC.Boot -> MainC;
  SendC.RadioControl -> ActiveMessageC;
  SendC.Packet -> ActiveMessageC;
  SendC.AMSend -> AMSenderC;

  SendC.Message -> SenseC;

}
