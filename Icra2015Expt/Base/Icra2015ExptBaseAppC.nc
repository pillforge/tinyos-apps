/**
 * This code is used for testing the miniature MCR board for our ICRA paper
 *
 * @auther Addisu Taddese
 * @date September 24 20014
 */

#include "Icra2015Expt.h"

configuration Icra2015ExptBaseAppC {
}
implementation {
  components Icra2015ExptBaseC as App, MainC;
  components new AMSenderC(AM_RADIOEXPTCOMMANDMSG);
  components new AMReceiverC(AM_RADIOEXPTDATAMSG);
  components new TimerMilliC();
  components ActiveMessageC;
  components SerialPrintfC;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;
  App.Timer -> TimerMilliC;
}
