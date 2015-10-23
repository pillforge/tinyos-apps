#ifndef DRUGDELIVERY_H_SWYI860V
#define DRUGDELIVERY_H_SWYI860V

typedef nx_struct RadioStatusMsg {
  nx_uint8_t status;
  nx_uint8_t data1;
  nx_uint32_t data2;
  nx_uint32_t data3;
} RadioStatusMsg;


typedef nx_struct RadioCommandMsg {
  nx_uint8_t cmd;
  nx_uint16_t sample_rate;
  nx_uint16_t motor_on_time;
  nx_uint8_t motor_duty_cycle;
} RadioCommandMsg;

typedef nx_struct RadioDataMsg {
  nx_uint8_t status;
} RadioDataMsg;

enum {
  AM_RADIOCOMMANDMSG = 5,
  AM_RADIODATAMSG = 6,
  AM_RADIOSTATUSMSG = 7
};

#endif /* end of include guard: DRUGDELIVERY_H_SWYI860V */
