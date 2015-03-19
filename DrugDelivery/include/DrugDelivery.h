#ifndef DRUGDELIVERY_H_SWYI860V
#define DRUGDELIVERY_H_SWYI860V

typedef nx_struct Accel_t {
  nx_int16_t x;
  nx_int16_t y;
  nx_int16_t z;
} Accel_t;

typedef Accel_t Gyro_t;


typedef nx_struct RadioCommandMsg{
  nx_uint8_t cmd;
  nx_uint16_t sample_rate;
  nx_uint16_t motor_on_time;
  nx_uint8_t motor_duty_cycle;
} RadioCommandMsg;

typedef nx_struct RadioDataMsg{
  nx_uint8_t msg[10];
} RadioDataMsg;

enum {
  AM_RADIOCOMMANDMSG = 5,
  AM_RADIODATAMSG = 6,
};

#endif /* end of include guard: DRUGDELIVERY_H_SWYI860V */

