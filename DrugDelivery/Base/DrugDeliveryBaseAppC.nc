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
  components ActiveMessageC;
  components SerialPrintfC;
  components HplMsp430GeneralIOC as GPIO;
  components PlatformSerialC as UartC;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;
  App.ScopeTrigger -> GPIO.Port40;
  App.UartStream -> UartC;
}
