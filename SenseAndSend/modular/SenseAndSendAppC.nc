#include "SenseAndSend.h"

configuration SenseAndSendAppC {
  
}

implementation {

  components TimerC;
  components MainC;
  components new TimerMilliC() as Timer1;
  TimerC.Boot -> MainC;
  TimerC.Timer -> Timer1;

  components SenseC;
  components Lsm330dlcC;
  SenseC.AccelRead -> Lsm330dlcC.AccelRead;

  components SendC;
  components ActiveMessageC;
  components new AMSenderC(AM_SENSORDATAMSG);
  SendC.Boot -> MainC;
  SendC.RadioControl -> ActiveMessageC;
  SendC.Packet -> ActiveMessageC;
  SendC.AMSend -> AMSenderC;

  SenseC.MessageReceive -> TimerC.Message;
  SendC.Message -> SenseC;

}
