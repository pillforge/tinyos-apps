#ifndef __CMA3000_D0X_H__
#define __CMA3000_D0X_H__

typedef nx_struct accel_t {
  nx_int8_t x;
  nx_int8_t y;
  nx_int8_t z;
} accel_t;

#define CMA3000_WHO_AM_I   0x00
#define CMA3000_REVID      0x01
#define CMA3000_CTRL       0x02
#define CMA3000_STATUS     0x03
#define CMA3000_RSTR       0x04
#define CMA3000_DOUTX      0x06
#define CMA3000_DOUTY      0x07
#define CMA3000_DOUTZ      0x08

#define CMA3000_CONFIG_G_RANGE_2G           0x80
#define CMA3000_CONFIG_G_RANGE_8G           0x00
#define CMA3000_CONFIG_I2C_DIS  0x10
#define CMA3000_CONFIG_MODE_MEAS_100     0x02
#define CMA3000_CONFIG_MODE_MEAS_400     0x04
#define CMA3000_CONFIG_MODE_MEAS_40      0x06

#endif /* end of include guard: __CMA3000_D0X_H__ */

