#include "cma3000-d0x.h"
#include "msp430.h"

generic module HplCma3000d0xP() {
  provides {
    interface Read<int16_t> as Accel;
    interface Msp430UsciConfigure;
    interface SplitControl;
    interface Init;
  }
  uses {
    interface BusyWait<TMicro, uint16_t>;
    interface SpiByte;
    interface Resource;
    interface HplMsp430GeneralIO as AccelPower;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430Interrupt as AccelInt;
    interface Leds;
    interface DiagMsg;
  }
}
implementation {
  const msp430_usci_config_t msp430_usci_spi_accel_config = {
    /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
    /*ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,*/
    ctl0 : UCCKPH | UCMSB | UCMST | UCSYNC,
    ctl1 : UCSSEL__SMCLK,
    br0  : 32,      /* 32x Prescale, 1*2^19 (512 KiHz) */
    br1  : 0,
    mctl : 0,
    i2coa: 0
  };

  bool deviceReady = FALSE;
  bool readRequest = FALSE;
  bool dataReady = FALSE;
  int16_t reading;

  command error_t SplitControl.start(){
    deviceReady = FALSE;
    call Resource.request();
    return SUCCESS;
  }


  command error_t Init.init(){
    call AccelCS.makeOutput();
    call AccelPower.makeOutput();
    call AccelCS.set();
    // We turn the power off and back on just to make sure a power cycle occurs.
    call AccelPower.clr();
    call BusyWait.wait(10000);
    call AccelPower.set();
    return SUCCESS;
  }

  /**
   * The CMA3000 uses a 16bit data frame. The first 8 bits include the address and whether
   * the instruction is a read or write. The second 8 bits are dummy bits.
   */
  uint8_t readRegister(uint8_t addr){
    uint8_t val;
    call AccelCS.clr();
    call SpiByte.write((addr << 2));
    val = call SpiByte.write(0);
    call AccelCS.set();
    return val;
  }

  /**
   * The CMA3000 uses a 16bit data frame. The first 8 bits include the address and the whether
   * the instruction is a read or write. The second 8 bits are the data bits to be written to the register.
   */
  uint8_t writeRegister(uint8_t addr, uint8_t data){
    uint8_t val;
    call AccelCS.clr();
    call SpiByte.write((addr << 2) + 2);
    val = call SpiByte.write(data);
    call AccelCS.set();
    return val;
  }

  inline void debugMsg(uint8_t id){
#ifdef CMA3000_DEBUG
    uint8_t ctrl, status;
    status = readRegister(CMA3000_STATUS);
    ctrl = readRegister(CMA3000_CTRL);

    call DiagMsg.record();
    call DiagMsg.uint8(id);
    call DiagMsg.str("s");
    call DiagMsg.uint8(status);
    call DiagMsg.str("c");
    call DiagMsg.uint8(ctrl);
    call DiagMsg.str("r");
    call DiagMsg.int8(reading);
    call DiagMsg.send();
#endif
  }

  inline void resetChip(){
    call AccelCS.clr();
    call SpiByte.write((CMA3000_RSTR<< 2) + 2);
    call SpiByte.write(0x2);
    call SpiByte.write(0xa);
    call SpiByte.write(0x4);
    call AccelCS.set();
    call BusyWait.wait(10000);
  }

  event void Resource.granted(){
    uint8_t status;
    
    resetChip();
    /*// wait for power on to complete*/
    do{
      status = readRegister(CMA3000_STATUS);
    }while(status != 0);

    debugMsg(0);
    // Loop until the ctrl register is set to what we want
    writeRegister(CMA3000_CTRL, CMA3000_CONFIG_G_RANGE_2G | CMA3000_CONFIG_MODE_MEAS_400 | CMA3000_CONFIG_I2C_DIS);
    call BusyWait.wait(30000);
    debugMsg(1);

    deviceReady = TRUE;
    signal SplitControl.startDone(SUCCESS);
  }

  task void powerdown(){
    call AccelPower.clr();
    signal SplitControl.stopDone(SUCCESS);
  }

  command error_t SplitControl.stop(){
    post powerdown();
    return SUCCESS;
  }

  task void readAccel_task(){
    atomic{
      if(dataReady){
        reading = (int16_t)((int8_t)readRegister(CMA3000_DOUTX));
        debugMsg(2);
        signal Accel.readDone(SUCCESS, reading);
        readRequest = FALSE;
        dataReady = FALSE;
      }
    }
  }

  command error_t Accel.read(){
    bool accelIntVal = FALSE;
    if(!readRequest && deviceReady){
      readRequest = TRUE;
      atomic accelIntVal = call AccelInt.getValue();
      if(accelIntVal){
        atomic dataReady = TRUE;
        post readAccel_task();
      }else{
        atomic {
          call AccelInt.edge(TRUE);
          call AccelInt.clear();
          call AccelInt.enable();
        }
      }
      return SUCCESS;
    }else {
      return EBUSY;
    }
  }

  async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
      return &msp430_usci_spi_accel_config;
  }

  async event void AccelInt.fired(){
    atomic dataReady = TRUE;
    atomic call AccelInt.clear();
    atomic call AccelInt.disable();
    post readAccel_task();
    call Leds.led1Toggle();
  }

}
