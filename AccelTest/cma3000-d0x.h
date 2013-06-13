#ifndef __CMA3000_D0X_H__
#define __CMA3000_D0X_H__

typedef struct accel_t
{
  int8_t x;
  int8_t y;
  int8_t z;
} accel_t;

#define CMA3000_WHO_AM_I   0x00
#define CMA3000_REVID      0x01
#define CMA3000_CTRL       0x02
#define CMA3000_STATUS     0x03
#define CMA3000_RSTR       0x04
#define CMA3000_DOUTX      0x06
#define CMA3000_DOUTY      0x07
#define CMA3000_DOUTZ      0x08

#endif /* end of include guard: __CMA3000_D0X_H__ */

