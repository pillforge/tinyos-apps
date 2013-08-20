generic module HplLis331dlhP() {
  provides {
    interface Read<int16_t> as Accel;
    interface Msp430UsciConfigure;
    interface SplitControl;
    interface Init;
  }
  uses {
    interface SpiByte;
    interface Resource;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430GeneralIO as AccelPower;
    interface HplMsp430Interrupt as AccelInt;
    interface Timer<TMilli> as Timer;
    interface DiagMsg;
  }
}
implementation {
  const msp430_usci_config_t msp430_usci_spi_accel_config = {
    /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
    /*ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,*/
       ctl0 : UCCKPH | UCMSB | UCMST | UCSYNC,
       ctl1 : UCSSEL__SMCLK,
       br0  : 16,      /* 32x Prescale, 1*2^19 (512 KiHz) */
       br1  : 0,
       mctl : 0,
       i2coa: 0
  };

  bool deviceReady = FALSE;
  int16_t reading;
  bool readRequest = FALSE;

  command error_t SplitControl.start(){
    deviceReady = FALSE;
    call Resource.request();
    return SUCCESS;
  }
  command error_t SplitControl.stop(){
    return FAIL;
  }

  command error_t Init.init(){
    call AccelCS.makeOutput();
    call AccelCS.set();
    return SUCCESS;
  }

  uint8_t readRegister(uint8_t addr){
    uint8_t val;
    call AccelCS.clr();
    call SpiByte.write((addr));
    val = call SpiByte.write(0);
    call AccelCS.set();
    return val;
  }

  uint8_t writeRegister(uint8_t addr, uint8_t data){
    uint8_t val;
    call AccelCS.clr();
    call SpiByte.write(addr);
    val = call SpiByte.write(data);
    call AccelCS.set();
    return val;
  }

  inline void debugMsg(uint8_t id){
#ifdef LIS331_DEBUG
    /*uint8_t ctrl, status;*/
    /*status = readRegister(CMA3000_STATUS);*/
    /*ctrl = readRegister(CMA3000_CTRL);*/

    call DiagMsg.record();
    /*call DiagMsg.uint8(id);*/
    /*call DiagMsg.str("s");*/
    /*call DiagMsg.uint8(status);*/
    /*call DiagMsg.str("c");*/
    /*call DiagMsg.uint8(ctrl);*/
    call DiagMsg.str("r");
    call DiagMsg.int16(reading);
    call DiagMsg.send();
#endif
  }
  event void Resource.granted(){
    uint8_t status;

    do {
      status = readRegister(LIS331DLH_WHO_I_AM);
    }
    while(status != 0x032);

    // Loop until the ctrl register is set to what we want
    writeRegister(LIS331DLH_CTRL1,LIS331DLH_CTRL1_SET);
    call Timer.startOneShot(30);

  }

  task void readAccel_task(){
    atomic{
      reading = (((int16_t) readRegister(LIS331DLH_AXh))<<8) + readRegister(LIS331DLH_AXl) ;
      /*reading.y = (((int16_t) readRegister(LIS331DLH_AYh))<<8) + readRegister(LIS331DLH_AYl) ;*/
      /*reading.z = (((int16_t) readRegister(LIS331DLH_AZh))<<8) + readRegister(LIS331DLH_AZl) ;*/
      debugMsg(2);
      signal Accel.readDone(SUCCESS, reading);
      readRequest = FALSE;
    }
  }

  command error_t Accel.read(){
    if(!readRequest && deviceReady){
      readRequest = TRUE;
      post readAccel_task();
      return SUCCESS;
    }else {
      return EBUSY;
    }
  }
  async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
    return &msp430_usci_spi_accel_config;
  }

  event void  Timer.fired(){
    deviceReady = TRUE;
    signal SplitControl.startDone(SUCCESS);
  }

  async event void AccelInt.fired(){}

}
