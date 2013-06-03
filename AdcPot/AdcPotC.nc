#include "Msp430Adc12.h"
module AdcPotC {
  uses {
    interface Boot;
    interface Read<uint16_t> as PotAdcRead;
    interface Timer<TMilli> as Timer1;
    interface HplMsp430GeneralIO as P80;
  }

  provides interface AdcConfigure <const msp430adc12_channel_config_t *> as PotAdcConfigure;

}
implementation {
  const msp430adc12_channel_config_t config = {
      inch: INPUT_CHANNEL_A5,
      sref: REFERENCE_VREFplus_AVss,
      ref2_5v: REFVOLT_LEVEL_1_5,
      adc12ssel: SHT_SOURCE_ACLK,
      adc12div: SHT_CLOCK_DIV_1,
      sht: SAMPLE_HOLD_4_CYCLES,
      sampcon_ssel: SAMPCON_SOURCE_SMCLK,
      sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  event void Boot.booted(){
    printf("App Booted.\r\n");
    // Turn P8.0 on so we get non zero values on the POT
    call P80.makeOutput();
    call P80.set();
    call Timer1.startPeriodic(100);
  }

  event void Timer1.fired(){
    call PotAdcRead.read();
  }

  event void PotAdcRead.readDone(error_t result, uint16_t data){
    printf("Adc: %d\r\n", data);
  }

  async command const msp430adc12_channel_config_t* PotAdcConfigure.getConfiguration(){
    return &config;
  }

}
