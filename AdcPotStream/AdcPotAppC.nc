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
  components new AdcReadStreamClientC() as PotAdc; 

  AdcPotC -> MainC.Boot;
  AdcPotC.PotAdcReadStream -> PotAdc.ReadStream;
  AdcPotC.PotAdcConfigure <- PotAdc.AdcConfigure;
  AdcPotC.P80 -> HplMsp430GeneralIOC.Port80;

}

