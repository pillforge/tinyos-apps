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
  components SerialPrintfC;
  App.Boot -> MainC.Boot;

  components new TimerMilliC() as Timer0;
  App.BeatTimer -> Timer0;
  components LedsC;
  App.Leds -> LedsC;

  components ActiveMessageC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;

  components new AMSenderC(AM_RADIOSTATUSMSG);
  App.AMSend -> AMSenderC;
  components new AMReceiverC(AM_RADIOSTATUSMSG);
  App.Receive -> AMReceiverC;


  

  

  components SerialActiveMessageC as SAM;
  App.SAMControl -> SAM;
  App.SAMReceive -> SAM.Receive[AM_DRUGSCHEDULERDATA];
  App.SAMSend -> SAM.AMSend[AM_DRUGSCHEDULERDATA];
  App.SAMPacket -> SAM;


}
