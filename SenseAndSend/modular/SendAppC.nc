#include "SenseAndSend.h"

configuration SenseAndSendAppC {
  
}

implementation {

  components SendC;
  components ActiveMessageC;
  components new AMSenderC(AM_SENSORDATAMSG);

  SendC.Boot -> MainC;
  SendC.RadioControl -> ActiveMessageC;
  SendC.Packet -> ActiveMessageC;
  SendC.AMSend -> AMSenderC;


}
