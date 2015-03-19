/**
 * This code is used for testing the miniature MCR board for a Drug Delivery capsule
 *
 * @auther Addisu Taddese
 * @date March 17 2015
 */

#include "DrugDelivery.h"

configuration DrugDeliveryAppC {
}
implementation {
  components DrugDeliveryC as App, MainC;
  components new AMSenderC(AM_RADIODATAMSG);
  components new AMReceiverC(AM_RADIOCOMMANDMSG);
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components ActiveMessageC;
  components HplMsp430GeneralIOC as GPIO;
  components SerialPrintfC;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;
  /*App.LowPowerListening -> ActiveMessageC;*/

  App.Timer -> Timer1;
  App.MotorTimer -> Timer2;

  components new MotorDriverGenericC(0) as M0;
  App.M0 -> M0;

  // Pin for powering up the boost regulator
  App.Boost_EN -> GPIO.Port40;
}
