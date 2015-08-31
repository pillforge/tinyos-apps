/**
 * This code is used for testing the miniature MCR board for a Drug delivery capsule
 *
 * @author Addisu Taddese
 * @date March 17 2015
 */

#include "DrugDelivery.h"
#include "DrugScheduler.h"

configuration DrugDeliveryBaseAppC {
}
implementation {
  components DrugDeliveryBaseC as App, MainC;
  components new AMSenderC(AM_RADIODRUGSCHEDULERMSG); // AM_RADIOCOMMANDMSG
  components new AMReceiverC(AM_RADIODATAMSG);
  components ActiveMessageC;
  components SerialPrintfC;
  components PlatformSerialC as UartC;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;
  App.UartStream -> UartC;
}
