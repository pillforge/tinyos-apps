/*
 * App to test I2C with an accelerometer 
 * @author Addisu Z. Taddese (addisu.z.taddese@vanderbilt.edu)
 *
 */

#include "printf.h"
configuration I2CTestAppC{
}
implementation {
  components I2CTestC, MainC, HplMsp430GeneralIOC as GPIO;
  components new Msp430UsciI2CB1C() as I2C;
  components new Msp430UsciI2CB1C() as I2CAccel;
  components SerialPrintfC;
  components new TimerMilliC();

  I2CTestC -> MainC.Boot;
  I2CTestC.I2CReg -> I2C;
  I2CTestC.I2CGyro -> I2C;
  I2CTestC.GyroResource -> I2C;

  I2CTestC.I2CAccel -> I2CAccel;
  I2CTestC.AccelResource -> I2CAccel;

  I2CTestC.Timer -> TimerMilliC;
}
