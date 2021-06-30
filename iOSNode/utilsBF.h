//
//  utils.h
//  iOSNode
//
//  Created by local on 5/11/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#ifndef utilsbf_h
#define utilsbf_h
#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

#define MIN1(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#define MAX1(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })

#define CLAMP(x, low, high) ({\
__typeof__(x) __x = (x); \
__typeof__(low) __low = (low);\
__typeof__(high) __high = (high);\
__x > __high ? __high : (__x < __low ? __low : __x);\
})

#endif /* utils_h */
