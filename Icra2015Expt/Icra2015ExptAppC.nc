/**
 * This code is used for testing the miniature MCR board for our ICRA paper
 *
 * @auther Addisu Taddese
 * @date September 24 20014
 */

#include "Icra2015Expt.h"

configuration Icra2015ExptAppC {
}
implementation {
  components Icra2015ExptC as App, MainC;
  components new AMSenderC(AM_RADIOEXPTDATAMSG);
  components new AMReceiverC(AM_RADIOEXPTCOMMANDMSG);
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

  components Lsm330dlcC;
  App.AccelRead -> Lsm330dlcC.AccelRead;
  App.GyroRead -> Lsm330dlcC.GyroRead;

}
