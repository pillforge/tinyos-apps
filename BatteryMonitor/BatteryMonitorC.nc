#include "ltc2942.h"
#include "Msp430Adc12.h"
#include <UserButton.h>

// NOTE:I2C WON'T WORK WITHOUT THIS DEFINE
#define MSP430_I2C_MASTER_MODE UCMST // single-master mode
#define MSP430_I2C_DIVISOR 80 // 100khz

#define USE_CONSTANT_CURRENT
#define CHECK_BATTERY_DEPLETION
#define USE_LTC2942

module BatteryMonitorC {
  uses {
    interface Boot;

    // I2C
    interface I2CReg;
    interface I2CPacket<TI2CBasicAddr>;
    interface BusyWait<TMicro, uint16_t>;
    interface Resource;
    interface HplMsp430GeneralIO as SDA;
    interface HplMsp430GeneralIO as SCL;

    interface Timer<TMilli> as PeriodTimer;
    interface Timer<TMilli> as ConvertionTimer;
    interface Timer<TMilli> as PseudoWdt;
    interface LocalTime<TMilli>;
    interface Notify<bool> as Button1;
    interface Notify<bool> as Button2;
    interface HplMsp430GeneralIO as Pwm_Out;

    // PWM
    interface Msp430Compare as TimerCompare0;
    interface Msp430Compare as TimerCompare1;
    interface Msp430TimerControl as TimerControl0;
    interface Msp430TimerControl as TimerControl1;
    interface Msp430Timer;

    // PWM Value Generator
    interface Get<uint16_t> as PwmVal;

    //Internal ADC
    interface Read<uint16_t> as CurrentRead;
    interface Read<uint16_t> as VoltageRead;

    interface HplMsp430GeneralIO as CurrentAdcInput;
    interface HplMsp430GeneralIO as VoltageAdcInput;

    // Leds
    interface Leds;


  }
  provides interface AdcConfigure <const msp430adc12_channel_config_t *> as CurrentAdcConfigure;
  provides interface AdcConfigure <const msp430adc12_channel_config_t *> as VoltageAdcConfigure;

}
implementation {

  enum  {
    /*S_TEMP,*/
    S_VOLT, // LTC2942
    S_ADC_VOLT,
    S_VOLT_I2C_READ,
    S_CURRENT,
    S_CHARGE,
  };
  enum {
    PWM_CLK_SRC_ACLK = 1,
    PWM_CLK_SRC_SMCLK= 2,
    TIMER_UP_MODE = 1,
  };


  const msp430adc12_channel_config_t current_adc_config = {
      inch: INPUT_CHANNEL_A7,
      sref: REFERENCE_VREFplus_AVss,
      /*sref: REFERENCE_AVcc_AVss,*/
      ref2_5v: REFVOLT_LEVEL_2_5,
      /*ref2_5v: REFVOLT_LEVEL_NONE,*/
      adc12ssel: SHT_SOURCE_ACLK,
      adc12div: SHT_CLOCK_DIV_1,
      sht: SAMPLE_HOLD_4_CYCLES,
      sampcon_ssel: SAMPCON_SOURCE_SMCLK,
      sampcon_id: SAMPCON_CLOCK_DIV_1
  };
  const msp430adc12_channel_config_t voltage_adc_config = {
      inch: INPUT_CHANNEL_A6,
      sref: REFERENCE_VREFplus_AVss,
      ref2_5v: REFVOLT_LEVEL_1_5,
      adc12ssel: SHT_SOURCE_ACLK,
      adc12div: SHT_CLOCK_DIV_1,
      sht: SAMPLE_HOLD_4_CYCLES,
      sampcon_ssel: SAMPCON_SOURCE_SMCLK,
      sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  typedef msp430_compare_control_t cc_t;

  task void gather_data();
  task void trigger_data();
  void reg_write_retry(uint16_t slave_addr, uint8_t reg, uint8_t val);
  void reg_read_retry(uint16_t slave_addr, uint8_t reg, uint8_t* val);
  void reset_i2c();

  norace uint8_t start_state = S_VOLT;
  norace uint8_t state;
  norace uint8_t button_check_period = 0;
  norace uint8_t current_ctrl_period = 0;
  norace bool current_ctrl_dir = TRUE;
  norace uint16_t charge = 0;
  norace uint16_t voltage_i2c = 0;
  norace uint16_t voltage_adc = 0;
  norace uint16_t current_adc= 0;
  norace bool voltage_ready = FALSE;
  /*norace uint16_t temperature = 0;*/
  norace bool should_reset_full = FALSE;
  norace bool should_reset_half = FALSE;
  norace bool should_reset_zero = FALSE;

  // Voltage state variables
  norace bool int_voltage_read = FALSE;
  norace bool i2c_voltage_read = FALSE;


  // Stats
  int32_t current_mean = 0;
  int32_t current_var = 0;
  uint8_t current_shift = 3;

  // I2C variables
  norace uint8_t i2c_data[2];
  norace bool i2c_error = SUCCESS;
  norace uint8_t i2c_charge_ctr = 0;
  norace uint16_t buffer = 0;
  norace uint8_t buffer16[16];

  norace uint16_t pwm_val = 0;
  norace uint16_t pwm_max = 0x1fff;


  norace int16_t depletion_count = 0;
  norace bool depletion_alert = FALSE;
  norace bool first_boot = TRUE;
  const uint16_t depletion_threshold = 10;
  const uint16_t depleted_voltage = 29400; // Voltage i2c
  /*const uint16_t depleted_voltage = 819; // with 0-1.5V ADC with 2.4V vref*/
  /*const uint16_t depleted_voltage = 44000;*/

  event void Boot.booted(){
    cc_t x;
    state = start_state;
    first_boot = TRUE;

    call TimerCompare0.setEvent(pwm_max);
    call TimerCompare1.setEvent(0);

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
    call Msp430Timer.setClockSource(PWM_CLK_SRC_SMCLK);
    call Msp430Timer.setMode(TIMER_UP_MODE); // Starts timer

    call CurrentAdcInput.makeInput();
    call VoltageAdcInput.makeInput();
    printf("Finished Booting...\n");

    call Button1.enable();
    call Button2.enable();

    P7DIR |= 7; // debug

    reset_i2c();
    // Request I2C resource
    call Resource.request();
  }

  void reset_charge(uint16_t val){
    // Set accumulated charge to 0xffff (Full battery)
    // Shutdown analog section
#ifdef USE_LTC2942
    reg_write_retry(LTC2942_ADDR, LTC2942_CONTROL_REG, 5);
    i2c_error |= call I2CReg.reg_write16(LTC2942_ADDR, LTC2942_ACCUM_CHARGE_MSB_REG, val);
    reg_write_retry(LTC2942_ADDR, LTC2942_CONTROL_REG, 4);
#endif
  }

  void reset_state_variables(){
    current_ctrl_dir = TRUE;
    current_ctrl_period  = 1;
    depletion_count = 0;
    depletion_alert = FALSE;
    call Leds.led1Off();

  }

  event void Resource.granted(){
    uint8_t status = 0;
    uint8_t i;


    i2c_error = SUCCESS;
    if (first_boot){

      /*printf("\nTime Temperature Charge Voltage\n");*/

      reset_charge(0xffff);
      i2c_error = call I2CReg.reg_readBlock(LTC2942_ADDR, LTC2942_STATUS_REG,16, buffer16);
      status = buffer16[0];
      if(i2c_error == SUCCESS){
        // No need to reset again
        first_boot = FALSE;
      }
      printf("I2C Status %x\n", status);
      printf("I2C Registers:\n");
      for(i=0; i < 16; i++) printf("%#02x ", buffer16[i]);
      printf("\n");
      
    }
    call PeriodTimer.startPeriodic(50);
    /*call PeriodTimer.startPeriodic(100);*/
    /*call PseudoWdt.startPeriodic(100);*/
  }

  event void PseudoWdt.fired(){

  }


  event void PeriodTimer.fired(){

    if(button_check_period==0){
      if(should_reset_zero){
        reset_charge(0);
        should_reset_zero = FALSE;
      }else if(should_reset_half){
        reset_charge(0x7fff);
        should_reset_half = FALSE;
        reset_state_variables();
      }else if(should_reset_full){
        reset_charge(0xffff);
        should_reset_full = FALSE;
        reset_state_variables();
      }
    }
    // If battery is completely depleted, turn off the current sink.
    // Here we are creating hysteresis so that a single (faulty) voltage reading doesn't trigger a depletion alert
    // Once depletion_count >= depletion_threshold, the depletion alert is implicitly triggered.
    //
#ifdef CHECK_BATTERY_DEPLETION
    if(depletion_count < depletion_threshold) {

      if(voltage_ready){
        if(voltage_i2c < depleted_voltage){
          depletion_count++;

          // Battery is depleted
          if(depletion_count >= depletion_threshold){
            call TimerCompare1.setEvent(0);
            call Leds.led1On();
            printf("0 0 0 0 0\n");
            depletion_alert = TRUE;
          }
        }else if (depletion_count > 0){
          depletion_count--;
        }
        voltage_ready = FALSE;
      }
    }
#endif

    if(!depletion_alert && (current_ctrl_period == 0)){
      // Only get a new value when current_adc has stabilized
      if(current_var < 100){
        pwm_val = call PwmVal.get();
        call Leds.led0Toggle();
        call TimerCompare1.setEvent(pwm_val);
      }  
    }
    /*call TimerCompare1.setEvent(pwm_clip);*/

    button_check_period = (button_check_period+1)%5;

    /*current_ctrl_period = (current_ctrl_period+1)%10;*/
    /*current_ctrl_period = (current_ctrl_period+1)%2;*/
    /*current_ctrl_period = (current_ctrl_period+1)%5;*/
    current_ctrl_period = 0;

    if(!depletion_alert)
      post trigger_data();
  }

  // This task is started by a timer. It sets off a chain of events between this task and the gather_data task 
  // that terminates when the gathered data is printed.
  task void trigger_data(){

    uint8_t ctrl_prefix = 0x00;
    switch(state){
      /*case S_TEMP:*/
      /*  ctrl_reg = ctrl_prefix | LTC2942_ADC_MODE_TEMPERATURE;*/
      /*  reg_write_retry(LTC2942_ADDR, LTC2942_CONTROL_REG, ctrl_reg);*/
      /*  call ConvertionTimer.startOneShot(10);*/
      /*  break;*/
      case S_VOLT:
        i2c_data[0] = LTC2942_CONTROL_REG;
        i2c_data[1] = ctrl_prefix | LTC2942_ADC_MODE_VOLTAGE;

        i2c_error |= call I2CPacket.write(I2C_START | I2C_STOP, LTC2942_ADDR, 2, i2c_data);

        break;
      case S_ADC_VOLT:
        P7OUT |= 2;
        /*call VoltageRead.read();*/
        // No ADC voltage
        int_voltage_read = TRUE;
        post gather_data();
        break;
      case S_VOLT_I2C_READ:
        i2c_data[0] = LTC2942_VOLT_MSB_REG;
        i2c_error |= call I2CPacket.write(I2C_START, LTC2942_ADDR, 1, i2c_data);
        break;

      case S_CURRENT:
        // internal Adc takes about 15 ms while the LTC2942 takes 10. So request both at the same time
        call CurrentRead.read();
        break;
      case S_CHARGE:
        // No need to write anything, proceed with reading the data
        /*call ConvertionTimer.startOneShot(5);*/

        i2c_data[0] = LTC2942_ACCUM_CHARGE_MSB_REG;
        i2c_error |= call I2CPacket.write(I2C_START, LTC2942_ADDR, 1, i2c_data);
        break;
    }

  }

  void reset_i2c(){
    // Reset I2C by setting both pins High for some amount of time
    call SDA.selectIOFunc();
    call SCL.selectIOFunc();

    call SDA.makeOutput();
    call SCL.makeOutput();

    call SCL.set();
    call Leds.led2On();
    call BusyWait.wait(400); 
    call Leds.led2Off();
    call SDA.set();
    
    call Leds.led2On();
    call Leds.led2Off();
    call Leds.led2On();
    call Leds.led2Off();
    call BusyWait.wait(1000); // 1 ms

    call SDA.selectModuleFunc();
    call SCL.selectModuleFunc();
    i2c_error = SUCCESS;
  }

  void reg_read_retry(uint16_t slave_addr, uint8_t reg, uint8_t *val){
#ifdef USE_LTC2942
    i2c_error |= call I2CReg.reg_read(slave_addr, reg, val);
#endif
  }

  void reg_read16_retry(uint16_t slave_addr, uint8_t reg, uint16_t *val){
#ifdef USE_LTC2942
    i2c_error |= call I2CReg.reg_read16(slave_addr, reg, val);
#endif
  }
  void reg_write_retry(uint16_t slave_addr, uint8_t reg, uint8_t val){
#ifdef USE_LTC2942
    i2c_error |= call I2CReg.reg_write(slave_addr, reg, val);
#endif
  }

  event void ConvertionTimer.fired(){
    // This is the only way I could think of doing this. When the timer fires, the ADC_Volt may or may not be ready. We
    // change state here so that we can issue the I2C request. In the mean time, if the ADC_Volt becomes ready,
    // gather_data should handle it properly.
    if(state == S_ADC_VOLT){
      state = S_VOLT_I2C_READ;
      post trigger_data();
    }
  }

  event void CurrentRead.readDone(error_t result, uint16_t data){
    current_adc = data;
    P7OUT &= ~2;
    // Fire timer so data can be sent
    post gather_data();

  }

  event void VoltageRead.readDone(error_t result, uint16_t data){
    int_voltage_read = TRUE;
    voltage_adc = data;
    P7OUT &= ~2;
    // Fire timer so data can be sent
    post gather_data();
  }


  task void gather_data(){
    uint32_t cur_time = 0;

    P7OUT |= 1;

    /*
     *As the ADC resolution of the Coulomb counter is 14-bit in voltage mode and 10-bit
     *in temperature mode, the lowest two bits of the combined
     *voltage registers (I, J) and the lowest six bits of the
     *combined temperature registers (M, N) are always zero.
     */

    if(i2c_error == SUCCESS){

      // State changes only happen here
      switch(state){
        /*case S_TEMP:*/
        /*  state = S_VOLT;*/
        /*  temperature = buffer;*/
        /*  post trigger_data();*/
        /*  break;*/
        case S_VOLT:
          voltage_ready = TRUE;
          state = S_ADC_VOLT;
          call ConvertionTimer.startOneShot(LTC2942_ADC_CONVERTION_TIME_MS);
          post trigger_data();
          break;
        case S_ADC_VOLT:
        case S_VOLT_I2C_READ:
          // Only change state after both voltages have been read.
          if(i2c_voltage_read && int_voltage_read){
            i2c_voltage_read = FALSE;
            int_voltage_read = FALSE;

            // Do stats
            // Running mean and variance calculation
            // u = (7*u + x)/8
            // var = (7*var + (x-u)^2)/8
            // We use shift instead of division
            current_mean = ((current_mean << current_shift) - current_mean + current_adc) >> current_shift;
            current_var = ((current_var << current_shift) - current_var + (current_adc - current_mean)*(current_adc - current_mean)) >> current_shift;

            state = S_CURRENT;
            post trigger_data();
          }
          break;
        case S_CURRENT:
          state = S_CHARGE;
          post trigger_data();
          break;
        default:
          state = start_state;
          // Print out
          cur_time = call LocalTime.get();

          if(!depletion_alert){
            printf("%lu %u %u %u %u\n", (unsigned long int)cur_time, charge, voltage_i2c, current_adc, pwm_val);
            /*printf("%lu %u %u %u %u %lu %lu\n", (unsigned long int)cur_time, charge, voltage_i2c, current_adc, pwm_val, current_mean, current_var);*/
          }
          break;
      }
    }else{
      // start over
      /*reset_i2c();*/
      P7OUT |= 4;
      state= start_state;
      call PeriodTimer.stop();
      // Release and request I2C bus so as to reset and restart the communication
      call Resource.release();
      call Resource.request();
      P7OUT &= ~4;
    }
    P7OUT &= ~(1);
  }

  async event void I2CPacket.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){
    i2c_error |= error;

    if(error == SUCCESS){
      switch(state){
        case S_VOLT_I2C_READ:
          i2c_voltage_read = TRUE;
          voltage_i2c = data[0] << 8 | data[1];
          break;
        case S_CHARGE:
          charge = data[0] << 8 | data[1];
          break;
      }

    }
    post gather_data();
  }

  async event void I2CPacket.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){
    i2c_error |= error;
    if(error == SUCCESS){
      switch(state){
        case S_VOLT:
          post gather_data();
          break;
        case S_VOLT_I2C_READ:
          i2c_error |=call I2CPacket.read(I2C_RESTART | I2C_STOP, LTC2942_ADDR, 2, (uint8_t *)&buffer);
          break;
        case S_CHARGE:
          charge = 0;
          i2c_error |= call I2CPacket.read(I2C_RESTART | I2C_STOP, LTC2942_ADDR, 2, (uint8_t *)&buffer);
          break;
      }
    }

    if(i2c_error != SUCCESS){
      post gather_data(); // Handles errors;
    }
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
  async event void Msp430Timer.overflow(){ }

  // Adc Configuration
  async command const msp430adc12_channel_config_t* CurrentAdcConfigure.getConfiguration(){
    return &current_adc_config;
  }

  async command const msp430adc12_channel_config_t* VoltageAdcConfigure.getConfiguration(){
    return &voltage_adc_config;
  }

}
