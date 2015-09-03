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
  components new AMSenderC(AM_DRUGSCHEDULERDATA); // AM_RADIOCOMMANDMSG
  components new AMReceiverC(AM_RADIODATAMSG);
  components ActiveMessageC;
  components SerialPrintfC;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;

  components SerialActiveMessageC as SAM;
  App.SAMControl -> SAM;
  App.SAMReceive -> SAM.Receive[AM_DRUGSCHEDULERDATA];
  App.SAMSend -> SAM.AMSend[AM_DRUGSCHEDULERDATA];
  App.SAMPacket -> SAM;

  components new TimerMilliC() as Timer;
  App.Timer -> Timer;
  components LedsC;
  App.Leds -> LedsC;

}
