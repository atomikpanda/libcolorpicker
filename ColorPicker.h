//
//  ColorPicker.h
//
//  Created by Bailey Seymour on 8/27/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//
//Place libcolorpicker.dylib in $THEOS/lib/
//Import this header and link with libcolorpicker.

#import "PFColorViewController.h"
#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif
UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback);
//old
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);

#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif
