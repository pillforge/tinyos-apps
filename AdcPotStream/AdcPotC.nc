#include "Msp430Adc12.h"
module AdcPotC {
  uses {
    interface Boot;
    interface ReadStream<uint16_t> as PotAdcReadStream;
    interface HplMsp430GeneralIO as P80;
  }

  provides interface AdcConfigure <const msp430adc12_channel_config_t *> as PotAdcConfigure;

}

#define BUFF_SIZE 128
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

  uint16_t buffer[BUFF_SIZE];

  task void sample(){
    call PotAdcReadStream.postBuffer(buffer, BUFF_SIZE);
    call PotAdcReadStream.read(10000);
  }

  event void Boot.booted(){
    size_t i;
    printf("App Booted %s.\r\n", __TIME__);
    // Turn P8.0 on so we get non zero values on the POT
    call P80.makeOutput();
    call P80.set();

    for(i = 0; i < BUFF_SIZE; i++){
      printf("Init %d: %d\r\n",i, buffer[i]);
    }

    post sample();
  }



  event void PotAdcReadStream.bufferDone(error_t result, uint16_t * buf, uint16_t count){
    size_t i;
    for(i = 0; i < count; i++){
      printf("%d\r\n", buf[i]);
    }
    post sample();
  }

  event void PotAdcReadStream.readDone(error_t result, uint32_t usActualPeriod){
    // Nothing to do.
  }

  async command const msp430adc12_channel_config_t* PotAdcConfigure.getConfiguration(){
    return &config;
  }

}
