#ifndef SENSEANDSEND_H_3ROYNNVF
#define SENSEANDSEND_H_3ROYNNVF

#include "Sense.h"

typedef nx_struct SensorDataMsg{
  Accel_t sensor_data;
} SensorDataMsg;

enum {
  AM_SENSORDATAMSG = 6,
};


#endif /* end of include guard: SENSEANDSEND_H_3ROYNNVF */
