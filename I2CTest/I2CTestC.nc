/**
 * lsm330dlc: Accelerometer and Gyroscope
 */

// NOTE:I2C WON'T WORK WITHOUT THIS DEFINE
#define MSP430_I2C_MASTER_MODE UCMST // single-master mode
#define MSP430_I2C_DIVISOR 20

#include "lsm330dlc.h"

module I2CTestC {
  uses {
    interface Boot;
    interface I2CReg;
    interface I2CPacket<TI2CBasicAddr> as I2CGyro;
    interface I2CPacket<TI2CBasicAddr> as I2CAccel;
    interface Resource as GyroResource;
    interface Resource as AccelResource;
    interface Timer<TMilli>;
  }
}

#define num_bytes 6
implementation {

  task void ReadGyroValues();
  task void WriteGyroDoneTask();
  task void ReadAccelValues();
  task void WriteAccelDoneTask();
  task void Runner();

  void configure_device();

  uint8_t accel[num_bytes]; // 3 axes, 2 bytes each
  uint8_t gyro[num_bytes]; // 3 axes, 2 bytes each

  uint8_t state = 0;
  event void Boot.booted(){
    error_t err;
    state = 0;
    printf("Booted\n");
    call GyroResource.request();
  }

  event void GyroResource.granted(){
    uint8_t who_am_i = 0;
    if(state == 0){
      state = 1;

      call I2CReg.reg_read(I2C_ADDRESS_G,WHO_AM_I_G, &who_am_i);
      if(who_am_i == LSM330DLC_DEVICE_ID){

        // Configure Accelerometer for 400 Hz, High resolution
        /*call I2CReg.reg_write(I2C_ADDRESS_A, CTRL_REG1_A, ACC_400_Hz_A | | xyz_en_A);*/
        call I2CReg.reg_write(I2C_ADDRESS_A, CTRL_REG1_A, ACC_1344_Hz_A | xyz_en_A);
        call I2CReg.reg_write(I2C_ADDRESS_A, CTRL_REG4_A, HR_A | ACC_2G_A);
        // Configure Gyro 

        call I2CReg.reg_write(I2C_ADDRESS_G, CTRL_REG1_G, DRBW_1000 | LPen_G | xyz_en_G);

        /*call Timer.startPeriodic(1);*/
        call GyroResource.release();
        post Runner();
      }

    } else {
      /*printf("%d: Gyro granted\n", call Timer.getNow());*/
      post ReadGyroValues();
    }
  }

  /*event void GyroResource.granted(){*/
  /*}*/

  event void AccelResource.granted(){
    /*printf("%d: Accel granted\n", call Timer.getNow());*/
    post ReadAccelValues();
  }
  /*void print_data(uint8_t length, uint8_t* data){*/
  void print_data(){
    int i = 0;
    /*printf("%d Bytes: ", length);*/
    /*for (i=0; i < length; i+=2)*/
    /*  printf("%02x %02x ", data[i+1],data[i]);*/

    /*printf("\t");*/

    printf("%d ", call Timer.getNow());
    for (i=0; i < num_bytes; i+=2)
      printf("%10d ", ((int)(gyro[i+1] << 8)+ gyro[i]));

    for (i=0; i < num_bytes; i+=2)
      printf("%10d ", ((int)(accel[i+1] << 8)+ accel[i]));

    printf("\n");
  }

  event void Timer.fired(){
    /*post ReadGyroValues();*/
    /*post ReadAccelValues();*/

    call GyroResource.request();
    call AccelResource.request();
    // print last value
    print_data();
  }
  task void Runner(){

    call GyroResource.request();
    call AccelResource.request();
    // print last value
    print_data();
    post Runner();
  }

  task void ReadGyroValues(){
    // Read 6 bytes from accelerometer
    uint8_t reg_write = XYZ_G;
    call I2CGyro.write(I2C_START, I2C_ADDRESS_G, 1, &reg_write);
  }

  task void WriteGyroDoneTask(){
    call I2CGyro.read(I2C_RESTART | I2C_STOP, I2C_ADDRESS_G, num_bytes, gyro);
  }


  async event void I2CGyro.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){
    /*print_data(length, data);*/
    call GyroResource.release();
  }

  async event void I2CGyro.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){
    post WriteGyroDoneTask();
  }

  task void ReadAccelValues(){
    // Read 6 bytes from accelerometer
    uint8_t reg_write = XYZ_A;
    call I2CAccel.write(I2C_START, I2C_ADDRESS_A, 1, &reg_write);
  }

  task void WriteAccelDoneTask(){
    call I2CAccel.read(I2C_RESTART | I2C_STOP, I2C_ADDRESS_A, num_bytes, accel);
  }

  async event void I2CAccel.readDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){
    call AccelResource.release();
  }

  async event void I2CAccel.writeDone(error_t error, uint16_t addr, uint8_t length, uint8_t* data){
    post WriteAccelDoneTask();
  }

}
