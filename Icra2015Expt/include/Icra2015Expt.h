#ifndef ICRA2015EXPT_H_SWYI860V
#define ICRA2015EXPT_H_SWYI860V

typedef nx_struct Accel_t {
  nx_int16_t x;
  nx_int16_t y;
  nx_int16_t z;
} Accel_t;

typedef Accel_t Gyro_t;


typedef nx_struct RadioExptCommandMsg{
  nx_uint8_t cmd;
  nx_uint16_t sample_rate;
  nx_uint16_t motor_on_time;
  nx_uint8_t motor_duty_cycle;
} RadioExptCommandMsg;

typedef nx_struct RadioExptDataMsg{
  Accel_t sensor_data;
} RadioExptDataMsg;

enum {
  AM_RADIOEXPTCOMMANDMSG = 5,
  AM_RADIOEXPTDATAMSG = 6,
};

#endif /* end of include guard: ICRA2015EXPT_H_SWYI860V */

