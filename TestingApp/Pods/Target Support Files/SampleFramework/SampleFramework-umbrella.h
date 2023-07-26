#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SampleFramework.h"
#import "WeScan.h"

FOUNDATION_EXPORT double SampleFrameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char SampleFrameworkVersionString[];

