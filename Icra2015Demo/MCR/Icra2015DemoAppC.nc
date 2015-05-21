/**
 * This code is used for testing the miniature MCR board for our ICRA paper
 *
 * @auther Addisu Taddese
 * @date September 24 20014
 */

#include "Icra2015Demo.h"

configuration Icra2015DemoAppC {
}
implementation {
  components Icra2015DemoC as App, MainC;
  components new AMSenderC(AM_RADIOEXPTDATAMSG);
  components new AMReceiverC(AM_RADIOEXPTCOMMANDMSG);
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components new TimerMilliC() as Timer3;
  components ActiveMessageC;
  /*components NoSleepC;*/
  /*components SerialPrintfC;*/

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  App.Acks -> AMSenderC;
  /*App.LowPowerListening -> ActiveMessageC;*/

  App.Timer -> Timer1;
  App.MotorTimer -> Timer2;

  components Lsm330dlcC;
  App.AccelRead -> Lsm330dlcC.AccelRead;
  App.GyroRead -> Lsm330dlcC.GyroRead;

  components new MotorDriverGenericC(0) as M0;
  App.M0 -> M0;

  // This probably belongs somewhere else. It is used to initialize all pwm pins as output low.
  components MotorMapC;
  App.PwmPin -> MotorMapC.HplMsp430GeneralIO[0];
  App.PwmPin -> MotorMapC.HplMsp430GeneralIO[1];
  App.PwmPin -> MotorMapC.HplMsp430GeneralIO[2];
  App.PwmPin -> MotorMapC.HplMsp430GeneralIO[3];
}
