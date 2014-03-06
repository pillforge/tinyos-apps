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

  norace uint8_t state = S_TEMP;
  norace uint16_t charge = 0;
  norace uint16_t voltage = 0;
  norace uint16_t temperature = 0;
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

    call PeriodTimer.startPeriodic(25);
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

  }

  event void ConvertionTimer.fired(){
    uint8_t write_reg = 0;
    uint32_t cur_time = 0;

    switch(state){
      case S_TEMP:
        write_reg = LTC2942_TEMP_MSB_REG;
        break;
      case S_VOLT:
        write_reg = LTC2942_VOLT_MSB_REG;
        break;
      default:
        write_reg = LTC2942_ACCUM_CHARGE_MSB_REG;
        break;
    }
    call I2CReg.reg_read16(LTC2942_ADDR, write_reg, &buffer);
    /*
     *As the ADC resolution is 14-bit in voltage mode and 10-bit
     *in temperature mode, the lowest two bits of the combined
     *voltage registers (I, J) and the lowest six bits of the
     *combined temperature registers (M, N) are always zero.
     */

    switch(state){
      case S_TEMP:
        state = S_VOLT;
        temperature = buffer;
        break;
      case S_VOLT:
        state = S_CHARGE;
        voltage = buffer;
        break;
      default:
        state = S_TEMP;
        charge = buffer;
        // Print out
        cur_time = call LocalTime.get();
        printf("%lu %u %u %u\n", (unsigned long int)cur_time, temperature, charge, voltage);
        break;
    }
  }

  async event void I2CPacket.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){}

  async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){

  }
}
