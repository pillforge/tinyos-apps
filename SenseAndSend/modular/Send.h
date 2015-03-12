#ifndef SEND_H_3ROYNNVF
#define SEND_H_3ROYNNVF

#define send_t Accel_t
#define to_send_addr_value 7

typedef nx_struct SendDataMsg{
  send_t sensor_data;
} SendDataMsg;

enum {
  AM_SENDDATAMSG = 6,
};


#endif
