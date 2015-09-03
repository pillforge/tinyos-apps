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
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components ActiveMessageC;
  components SerialPrintfC;

  App.Boot -> MainC.Boot;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;

  App.Timer -> Timer1;
  App.MotorTimer -> Timer2;

  components new MotorDriverGenericC(0) as M0;
  App.M0 -> M0;

  components DrugSchedulerC;
  App.DrugSchedulerI -> DrugSchedulerC;

  components new TimerMilliC() as Timer3;
  App.BeatTimer -> Timer3;
  components LedsC;
  App.Leds -> LedsC;

}
