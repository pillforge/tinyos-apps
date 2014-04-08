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
  components HplMsp430GeneralIOC as GeneralIOC;
  components HplMsp430InterruptC as InterruptC;
  components Msp430TimerC;
  components new AdcReadClientC() as Adc; 


  components new SwitchToggleC() as Button1;
  components new Msp430InterruptC() as Button1Intr;

  Button1.HplMsp430GeneralIO -> GeneralIOC.Port17;
  Button1.GpioInterrupt -> Button1Intr;
  Button1Intr.HplInterrupt -> InterruptC.Port17;

  components new SwitchToggleC() as Button2;
  components new Msp430InterruptC() as Button2Intr;

  Button2.HplMsp430GeneralIO -> GeneralIOC.Port22;
  Button2.GpioInterrupt -> Button2Intr;
  Button2Intr.HplInterrupt -> InterruptC.Port22;

  BatteryMonitorC -> MainC.Boot;
  BatteryMonitorC.PeriodTimer -> Timer0;
  BatteryMonitorC.ConvertionTimer -> Timer1;
  BatteryMonitorC.I2CReg -> I2C;
  BatteryMonitorC.I2CPacket -> I2C;
  BatteryMonitorC.Resource -> I2C;
  BatteryMonitorC.LocalTime -> LocalTimeMilliC;
  BatteryMonitorC.Button1 -> Button1;
  BatteryMonitorC.Button2 -> Button2;
  BatteryMonitorC.Pwm_Out -> GeneralIOC.Port40;


  BatteryMonitorC.TimerControl0 -> Msp430TimerC.Control0_B0;
  BatteryMonitorC.TimerCompare0 -> Msp430TimerC.Compare0_B0;

  BatteryMonitorC.TimerControl1 -> Msp430TimerC.Control0_B1;
  BatteryMonitorC.TimerCompare1 -> Msp430TimerC.Compare0_B1;

  BatteryMonitorC.Msp430Timer -> Msp430TimerC.Timer0_B;

  // Adc
  BatteryMonitorC.AdcRead -> Adc.Read;
  BatteryMonitorC.AdcConfigure <- Adc.AdcConfigure;
  BatteryMonitorC.AdcInput -> GeneralIOC.Port67;

  // Leds
  components LedsC;
  BatteryMonitorC.Leds -> LedsC;
}
