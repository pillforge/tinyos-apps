/*
 * App to test the ADC by printing the value of the potentiometer on the EXP430 board.
 *
 * @author Addisu Z. Taddese (addisu.z.taddese@vanderbilt.edu)
 *
 */

#include "printf.h"
configuration AdcPotAppC{
}
implementation {
  components AdcPotC, MainC, HplMsp430GeneralIOC;
  components SerialPrintfC;
  components new AdcReadClientC() as PotAdc; 
  components new TimerMilliC() as Timer1; 

  AdcPotC -> MainC.Boot;
  AdcPotC.PotAdcRead -> PotAdc.Read;
  AdcPotC.PotAdcConfigure <- PotAdc.AdcConfigure;
  AdcPotC.Timer1 -> Timer1;
  AdcPotC.P80 -> HplMsp430GeneralIOC.Port80;

}

