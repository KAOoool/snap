/*
 * Copyright 2017 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __SNAP_H265ENC__
#define __SNAP_H265ENC__

/*
 * This makes it obvious that we are influenced by HLS details ...
 * The ACTION control bits are defined in the following file.
 */
//#include <snap_hls_if.h>
#define ACTION_TYPE_HDL_H265ENC 0x00000001	/* Action Type */

#define REG_START               0x34	
#define REG_X_TOTAL             0x38
#define REG_Y_TOTAL             0x3c	
#define REG_QP                  0x40
#define REG_TYPE                0x44
#define REG_ORI_BASE_HIGH       0x48
#define REG_ORI_BASE_LOW        0x4C
#define REG_REC_0_BASE          0x50
#define REG_REC_1_BASE          0x54
#define COUNT_A                 0x58
#define SYS_DONE_I              0x5C
#define REG_BS_BASE_HIGH        0x60
#define REG_BS_BASE_LOW         0x64

#define FRAMEWIDTH              2560
#define FRAMEHEIGHT             1600
#define X_TOTAL                 (FRAMEWIDTH /64)-1
#define Y_TOTAL                 (FRAMEHEIGHT /64)-1
#define QP                      0x00000016
#define REC_0_BASE              (FRAMEWIDTH*FRAMEHEIGHT*3/2)*1 
#define REC_1_BASE              (FRAMEWIDTH*FRAMEHEIGHT*3/2)*2


#endif	/* __SNAP_H265ENC__ */
