#include "ltc2942.h"
#include "Msp430Adc12.h"
#include <UserButton.h>

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
    interface Notify<bool> as Button1;
    interface Notify<bool> as Button2;
    interface HplMsp430GeneralIO as Pwm_Out;

    // PWM
    interface Msp430Compare as TimerCompare0;
    interface Msp430Compare as TimerCompare1;
    interface Msp430TimerControl as TimerControl0;
    interface Msp430TimerControl as TimerControl1;
    interface Msp430Timer as TimerB;

    //Internal ADC
    interface Read<uint16_t> as AdcRead;
    interface HplMsp430GeneralIO as AdcInput;
  }
  provides interface AdcConfigure <const msp430adc12_channel_config_t *> as AdcConfigure;

}
implementation {

  enum  {
    S_TEMP,
    S_VOLT,
    S_CHARGE,
    S_ADC,
  };
  enum {
    PWM_CLK_SRC_ACLK = 1,
    PWM_CLK_SRC_SMCLK= 2,
    TIMER_UP_MODE = 1,
  };

  const msp430adc12_channel_config_t config = {
      inch: INPUT_CHANNEL_A7,
      /*sref: REFERENCE_VREFplus_AVss,*/
      sref: REFERENCE_AVcc_AVss,
      /*ref2_5v: REFVOLT_LEVEL_2_5,*/
      ref2_5v: REFVOLT_LEVEL_NONE,
      adc12ssel: SHT_SOURCE_ACLK,
      adc12div: SHT_CLOCK_DIV_1,
      sht: SAMPLE_HOLD_4_CYCLES,
      sampcon_ssel: SAMPCON_SOURCE_SMCLK,
      sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  typedef msp430_compare_control_t cc_t;

  norace uint8_t state = S_TEMP;
  norace uint8_t button_check_period = 0;
  norace uint8_t current_ctrl_period = 0;
  norace uint8_t current_ctrl_val = 1;
  norace bool current_ctrl_dir = TRUE;
  norace uint16_t charge = 0;
  norace uint16_t voltage = 0;
  norace uint16_t temperature = 0;
  norace uint16_t int_adc = 0;
  norace uint16_t buffer = 0;
  norace bool should_reset_full = FALSE;
  norace bool should_reset_half = FALSE;
  norace bool should_reset_zero = FALSE;
  norace uint16_t pwm_clip = 0x3f;

  event void Boot.booted(){
    cc_t x;
    call TimerCompare0.setEvent(0xff);
    // 0x7ff = 35.062 ma
    // 0x7ff = 17 ma
    // 0x3ff = 8.766 ma
    call TimerCompare1.setEvent(current_ctrl_val);

    call TimerControl0.setControlAsCompare();
    call TimerControl1.setControlAsCompare();

    call TimerControl0.enableEvents();
    call TimerControl1.enableEvents();

    // Set output direction
    call Pwm_Out.selectModuleFunc();
    call Pwm_Out.makeOutput();

    // Set output mode
    x = call TimerControl1.getControl();
    x.outmod = 7; // Enable set/reset output mode
    call TimerControl1.setControl(x);

    // Select clock source and count mode
    call TimerB.setClockSource(PWM_CLK_SRC_SMCLK);
    call TimerB.setMode(TIMER_UP_MODE); // Starts timer

    // Setup ADC
    call AdcInput.selectModuleFunc();
    call AdcInput.makeInput();

    // Request I2C resource
    call Resource.request();
  }

  void reset_charge(uint16_t val){
    // Set accumulated charge to 0xffff (Full battery)
    // Shutdown analog section
    call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, 1);
    buffer = val;
    call I2CReg.reg_write16(LTC2942_ADDR, LTC2942_ACCUM_CHARGE_MSB_REG, buffer);
  }

  event void Resource.granted(){
    uint8_t status = 0;

    call Button1.enable();
    call Button2.enable();

    /*printf("\nTime Temperature Charge Voltage\n");*/
    printf("Temperature Charge Voltage\n");
    call I2CReg.reg_read(LTC2942_ADDR, LTC2942_STATUS_REG, &status);

    reset_charge(0xffff);
    call PeriodTimer.startPeriodic(25);
  }


  event void PeriodTimer.fired(){

    uint8_t ctrl_reg = 0;
    uint8_t ctrl_prefix = 0x04;

    if(button_check_period==0){
      if(should_reset_zero){
        reset_charge(0);
        should_reset_zero = FALSE;
      }else if(should_reset_half){
        reset_charge(0x7fff);
        should_reset_half = FALSE;
      }else if(should_reset_full){
        reset_charge(0xffff);
        should_reset_full = FALSE;
      }
    }
    if(current_ctrl_period == 0){
      current_ctrl_val = (current_ctrl_val + 1) % pwm_clip;
      if(current_ctrl_val == 0)
        current_ctrl_dir = !current_ctrl_dir;

      if(current_ctrl_dir){
        call TimerCompare1.setEvent(current_ctrl_val);
      } else{
        call TimerCompare1.setEvent(pwm_clip-current_ctrl_val);
      }
    }

    button_check_period = (button_check_period+1)%5;

    current_ctrl_period = (current_ctrl_period+1)%2;

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
      case S_CHARGE:
        ctrl_reg = ctrl_prefix;
        call I2CReg.reg_write(LTC2942_ADDR, LTC2942_CONTROL_REG, ctrl_reg);
        call ConvertionTimer.startOneShot(1);
      default:
        call AdcRead.read();
    }

  }
  event void AdcRead.readDone(error_t result, uint16_t data){
    int_adc = data;
    // Fire timer so data can be sent
    call ConvertionTimer.startOneShot(1);
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
      case S_CHARGE:
        write_reg = LTC2942_ACCUM_CHARGE_MSB_REG;
        break;
    }
    if(state != S_ADC)
      call I2CReg.reg_read16(LTC2942_ADDR, write_reg, &buffer);

    /*
     *As the ADC resolution of the Coulomb counter is 14-bit in voltage mode and 10-bit
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
      case S_CHARGE:
        state = S_ADC;
        charge = buffer;
        break;
      default:
        state = S_TEMP;
        // Print out
        cur_time = call LocalTime.get();
        /*printf("%lu %u %u %u %u\n", (unsigned long int)cur_time, temperature, charge, voltage, int_adc);*/
        printf("%lu %u %u %u %u %u %u\n", (unsigned long int)cur_time, temperature, charge, voltage, int_adc, current_ctrl_dir, current_ctrl_val);
        /*printf("%u %u %u\n", temperature, charge, voltage);*/
        break;
    }
  }

  async event void I2CPacket.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){}

  async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){

  }

  event void Button1.notify(bool val){
    if(val){
      should_reset_full = TRUE;
      /*printf("\nTime Temperature Charge Voltage\n");*/
    }
  }
  event void Button2.notify(bool val){
    if(val){
      if(should_reset_half){ // If double press, reset to zero
        should_reset_zero = TRUE;
        should_reset_half = FALSE;
      }else
        should_reset_half = TRUE;
      /*printf("\nTime Temperature Charge Voltage\n");*/
    }
  }

  async event void TimerCompare0.fired(){ }
  async event void TimerCompare1.fired(){ }
  async event void TimerB.overflow(){ }

  // Adc Configuration
  async command const msp430adc12_channel_config_t* AdcConfigure.getConfiguration(){
    return &config;
  }

}
