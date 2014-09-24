#ifndef ICRA2015EXPT_H_SWYI860V
#define ICRA2015EXPT_H_SWYI860V

typedef nx_struct Accel_t {
  nx_uint16_t x;
  nx_uint16_t y;
  nx_uint16_t z;
} Accel_t;

typedef Accel_t Gyro_t;


typedef nx_struct RadioExptCommandMsg{
  nx_uint8_t cmd;
} RadioExptCommandMsg;

typedef nx_struct RadioExptDataMsg{
  Accel_t sensor_data;
} RadioExptDataMsg;

enum {
  AM_RADIOEXPTCOMMANDMSG = 5,
  AM_RADIOEXPTDATAMSG = 5,
};

#endif /* end of include guard: ICRA2015EXPT_H_SWYI860V */

