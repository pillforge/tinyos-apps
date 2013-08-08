#ifndef __ACCEL_TEST_H__
#define __ACCEL_TEST_H__

#include "cma3000-d0x.h"

enum{
  AM_ACCEL_MSG = 2,
};

typedef struct angle_t{
    float x;
    float y;
    float z;
}angle_t;

typedef struct accel_msg {
    accel_t accel;
    angle_t angle;
}accel_msg;


#endif /* end of include guard: __ACCEL_TEST_H__ */
