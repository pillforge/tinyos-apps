/**
 * This code is used for testing the miniature MCR board for a Drug delivery capsule
 *
 * @author Addisu Taddese
 * @date March 17 2015
 */

#include "DrugDelivery.h"

configuration DrugDeliveryBaseAppC {
}
implementation {
  components DrugDeliveryBaseC as App, MainC;
  components new AMSenderC(AM_RADIOCOMMANDMSG);
  components new AMReceiverC(AM_RADIODATAMSG);
  components new TimerMilliC();
  components ActiveMessageC;
  components SerialPrintfC;
  components HplMsp430GeneralIOC as GPIO;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;
  App.Timer -> TimerMilliC;
  App.ScopeTrigger -> GPIO.Port40;
}
