#include "Send.h"

configuration SendAppC {

}

implementation {

  components SendC;
  components ActiveMessageC;
  components new AMSenderC(AM_SENDDATAMSG);

  SendC.Boot -> MainC;
  SendC.RadioControl -> ActiveMessageC;
  SendC.Packet -> ActiveMessageC;
  SendC.AMSend -> AMSenderC;

}
