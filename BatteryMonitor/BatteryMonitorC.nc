#include "ltc2942.h"

// NOTE:I2C WON'T WORK WITHOUT THIS DEFINE
#define MSP430_I2C_MASTER_MODE UCMST // single-master mode
#define MSP430_I2C_DIVISOR 20

module BatteryMonitorC {
  uses {
    interface Boot;
    interface I2CReg;
    interface I2CPacket<TI2CBasicAddr>;
    interface Resource;
    interface Timer<TMilli> as PeriodTimer;
    interface Timer<TMilli> as ConvertionTimer;
    interface LocalTime<TMilli>;
  }

}
implementation {

  enum  {
    S_TEMP,
    S_VOLT,
    S_CHARGE,
  };

  norace uint8_t state = S_CHARGE;
  norace uint16_t buffer = 0;

  event void Boot.booted(){
    call Resource.request();
  }

  event void Resource.granted(){

    uint8_t status = 0;
    call I2CReg.reg_read(LTC2942_ADDR, LTC2942_STATUS_REG, &status);
    // Shutdown analog section
    call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, 1);

    // Set accumulated charge to 0xffff (Full battery)
    buffer = 0xffff;
    call I2CReg.reg_write16(LTC2942_ADDR, LTC2942_ACCUM_CHARGE_MSB_REG, buffer);

    call PeriodTimer.startPeriodic(50);
  }

  event void PeriodTimer.fired(){

    uint8_t ctrl_reg = 0;
    uint8_t ctrl_prefix = 0x04;

    switch(state){
      case S_TEMP:
        ctrl_reg = ctrl_prefix | LTC2942_ADC_MODE_TEMPERATURE;
        call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, ctrl_reg);
        call ConvertionTimer.startOneShot(10);
        break;
      case S_VOLT:
        ctrl_reg = ctrl_prefix | LTC2942_ADC_MODE_VOLTAGE;
        call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, ctrl_reg);
        call ConvertionTimer.startOneShot(10);
        break;
      default:
        ctrl_reg = ctrl_prefix;
        call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, ctrl_reg);
        call ConvertionTimer.startOneShot(1);
    }

    /*call I2CReg.reg_read(LTC2942_ADDR, LTC2942_CONTROL_REG, &ctrl_reg);*/
    /*ctrl_reg = (ctrl_reg & 0x3f) | (1 << 6); //temperature*/
    /*call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, ctrl_reg);*/


  }

  event void ConvertionTimer.fired(){
    uint8_t write_reg = 0;
    uint32_t cur_time = 0;

    switch(state){
      case S_TEMP:
        write_reg = LTC2942_TEMP_MSB_REG;
        /*state = S_VOLT;*/
        break;
      case S_VOLT:
        write_reg = LTC2942_VOLT_MSB_REG;
        /*state = S_CHARGE;*/
        break;
      default:
        write_reg = LTC2942_ACCUM_CHARGE_MSB_REG;
        /*state = S_TEMP;*/
        break;
    }
    /*call I2CPacket.write(I2C_START , LTC2942_ADDR, 1, &write_reg);*/
    call I2CReg.reg_read16(LTC2942_ADDR, write_reg, &buffer);
    /*
     *As the ADC resolution is 14-bit in voltage mode and 10-bit
     *in temperature mode, the lowest two bits of the combined
     *voltage registers (I, J) and the lowest six bits of the
     *combined temperature registers (M, N) are always zero.
     */
    /*printf("%d %u\n", call LocalTime.get(), buffer);*/

    cur_time = call LocalTime.get();
    printf("%lu %u\n", (unsigned long int)cur_time, buffer);
  }

  async event void I2CPacket.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){}

  async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){

    /*call I2CPacket.read(I2C_RESTART | I2C_STOP, LTC2942_ADDR, 2, (uint8_t *)&buffer);*/
    /*switch(state){*/
    /*  case S_TEMP:*/
    /*    state = S_VOLT;*/
    /*    break;*/
    /*  case S_VOLT:*/
    /*    state = S_CHARGE;*/
    /*    break;*/
    /*  default:*/
    /*    state = S_TEMP;*/
    /*    break;*/
    /*}*/
  }
}
