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
  components AdcPotC, MainC;
  components SerialPrintfC;

  AdcPotC -> MainC.Boot;

}

