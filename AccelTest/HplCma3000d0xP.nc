generic module HplCma3000d0xP() {
  provides {
    interface Read<accel_t> as Accel;
    interface Init;
    interface Msp430UsciConfigure;
  }
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as AccelPower;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430GeneralIO as AccelInt;
    interface Timer<TMilli> as TimerMs;
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
  command error_t Init.init(){
    call SpiResource.request();
    return SUCCESS;
  }

  event void SpiResource.granted(){
    printf("Resource Granted\r\n");
    call AccelCS.makeOutput();
    call AccelPower.makeOutput();
    call AccelInt.makeInput();
    call AccelCS.set();
    call AccelPower.clr();
    call AccelPower.set();
    call TimerMs.startOneShot(100);
  }

  event void TimerMs.fired(){
    uint8_t rx1, rx2, who_am_i, revid;
    printf("Timer fired\r\n");

    call AccelCS.clr();
    call SpiByte.write((CMA3000_WHO_AM_I << 2));
    who_am_i = call SpiByte.write(0x4);
    call AccelCS.set();

    call AccelCS.clr();
    call SpiByte.write((CMA3000_REVID << 2));
    revid = call SpiByte.write(0x4);
    call AccelCS.set();

    printf("WHO %#x, REV %#x\r\n", who_am_i, revid);

    call AccelCS.clr();
    rx1 = call SpiByte.write((CMA3000_CTRL << 2) + 2);
    rx2 = call SpiByte.write(0x4);
    call AccelCS.set();
    printf("RX1 %#x, RX2 %#x\r\n", rx1, rx2);
    printf("Set to measure mode\r\n");
    // Read CTRL register
    call AccelCS.clr();
    call SpiByte.write((CMA3000_CTRL << 2));
    rx1 = call SpiByte.write(0);
    call AccelCS.set();
    // Read status register
    call AccelCS.clr();
    call SpiByte.write((CMA3000_STATUS << 2));
    rx2 = call SpiByte.write(0);
    call AccelCS.set();
    printf("CTRL %#x STATUS %#x\r\n", rx1, rx2);
  }

  task void readAccel_task(){
    accel_t reading;
    /*while(!call AccelInt.get());*/
    call AccelCS.clr();
    call SpiByte.write(CMA3000_DOUTX << 2);
    reading.x = call SpiByte.write(0);
    call AccelCS.set();
    call AccelCS.clr();
    call SpiByte.write(CMA3000_DOUTY << 2);
    reading.y = call SpiByte.write(0);
    call AccelCS.set();
    call AccelCS.clr();
    call SpiByte.write(CMA3000_DOUTZ << 2);
    reading.z = call SpiByte.write(0);
    call AccelCS.set();

    signal Accel.readDone(SUCCESS, reading);
  }

  command error_t Accel.read(){
    post readAccel_task();
    return SUCCESS;
  }

  async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
      return &msp430_usci_spi_accel_config;
  }

}
