#ifndef DRUGDELIVERY_H_SWYI860V
#define DRUGDELIVERY_H_SWYI860V

typedef nx_struct RadioCommandMsg {
  nx_uint8_t cmd;
  nx_uint16_t sample_rate;
  nx_uint16_t motor_on_time;
  nx_uint8_t motor_duty_cycle;
} RadioCommandMsg;

typedef nx_struct RadioDataMsg {
  nx_uint8_t remaining_drug;
} RadioDataMsg;

enum {
  AM_RADIOCOMMANDMSG = 5,
  AM_RADIODATAMSG = 6,
};

#endif /* end of include guard: DRUGDELIVERY_H_SWYI860V */
