/*
 * App to use the ltc2942 battery gauge
 * @author Addisu Z. Taddese (addisu.z.taddese@vanderbilt.edu)
 *
 */

#include "printf.h"
configuration BatteryMonitorAppC{
}
implementation {
  components BatteryMonitorC, MainC;
  components new Msp430UsciI2CB1C() as I2C;
  components new TimerMilliC() as Timer0, new TimerMilliC() as Timer1;
  components SerialPrintfC, LocalTimeMilliC;

  BatteryMonitorC -> MainC.Boot;
  BatteryMonitorC.PeriodTimer -> Timer0;
  BatteryMonitorC.ConvertionTimer -> Timer1;
  BatteryMonitorC.I2CReg -> I2C;
  BatteryMonitorC.I2CPacket -> I2C;
  BatteryMonitorC.Resource -> I2C;
  BatteryMonitorC.LocalTime -> LocalTimeMilliC;
}
