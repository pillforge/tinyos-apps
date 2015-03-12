#ifndef SENSE_H_3ROYNNVF
#define SENSE_H_3ROYNNVF

#define sample_rate_value 100

typedef nx_struct Accel_t {
  nx_int16_t x;
  nx_int16_t y;
  nx_int16_t z;
} Accel_t;

typedef Accel_t Gyro_t;

#endif
