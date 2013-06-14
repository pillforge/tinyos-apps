generic module HplCma3000d0xP() {
  provides {
    interface Read<accel_t> as Accel;
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
  }
}
implementation {
  const msp430_usci_config_t msp430_usci_spi_accel_config = {
    /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
    /*ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,*/
    ctl0 : UCCKPH | UCMSB | UCMST | UCSYNC,
    ctl1 : UCSSEL__SMCLK,
    br0  : 32,			/* 32x Prescale, 1*2^19 (512 KiHz) */
    br1  : 0,
    mctl : 0,
    i2coa: 0
  };

  bool deviceReady = FALSE;
  command error_t SplitControl.start(){
    deviceReady = FALSE;
    call Resource.request();
    return SUCCESS;
  }

  event void Resource.granted(){
    call AccelCS.makeOutput();
    call AccelPower.makeOutput();
    call AccelCS.set();
    call AccelPower.set();
    call BusyWait.wait(10000);
    signal SplitControl.startDone(SUCCESS);
  }

  command error_t SplitControl.stop(){
    call AccelPower.clr();
  }

  /**
   * The CMA3000 uses a 16bit data frame. The first 8 bits include the address and the whether
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

  accel_t reading;
  bool dataReady = FALSE;
  task void readAccel_task(){
    atomic{
      if(dataReady) {
        reading.x = readRegister(CMA3000_DOUTX);
        reading.y = readRegister(CMA3000_DOUTY);
        reading.z = readRegister(CMA3000_DOUTZ);
        dataReady = FALSE;
      }
    }
    atomic signal Accel.readDone(SUCCESS, reading);
    post readAccel_task();
  }


  command error_t Init.init(){
    uint8_t rx, who_am_i, revid, ctrl, status;
    printf("Timer fired\r\n");

    who_am_i = readRegister(CMA3000_WHO_AM_I);
    revid = readRegister(CMA3000_REVID);
    printf("WHO %#x, REV %#x\r\n", who_am_i, revid);

    rx = writeRegister(CMA3000_CTRL,0x4);
    printf("RX %#x\r\n", rx);
    printf("Set to measure mode\r\n");

    // Read back CTRL register
    ctrl = readRegister(CMA3000_CTRL);
    // Read status register
    status = readRegister(CMA3000_STATUS);

    printf("CTRL %#x STATUS %#x\r\n", ctrl, status);
    // Enable interrupt

    atomic{
      call AccelInt.edge(TRUE);
      call AccelInt.clear();
      call AccelInt.enable();
    }
    deviceReady = TRUE;
    post readAccel_task();
    return SUCCESS;
  }


  command error_t Accel.read(){
    if(deviceReady){
      atomic dataReady = TRUE;
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
  }

}
