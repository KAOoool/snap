#ifndef  __CONFIG_H_
#define  __CONFIG_H_

#define GOP_LENGTH              1

#define FRAMEWIDTH              448
#define FRAMEHEIGHT             256

#define QP                      0x00000016
#define X_TOTAL                 (FRAMEWIDTH /64)-1
#define Y_TOTAL                 (FRAMEHEIGHT /64)-1
#define REC_0_BASE              (FRAMEWIDTH*FRAMEHEIGHT*3/2)*1 
#define REC_1_BASE              (FRAMEWIDTH*FRAMEHEIGHT*3/2)*2

#endif

