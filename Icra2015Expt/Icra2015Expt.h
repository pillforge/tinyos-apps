#ifndef ICRA2015EXPT_H_SWYI860V
#define ICRA2015EXPT_H_SWYI860V
#include "Lsm330dlc.h"

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

