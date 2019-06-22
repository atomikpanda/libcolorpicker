//
//  PFColorTransparentView.m
//  ColorPickerTestApp
//
//  Created by Bailey Seymour on 8/27/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//

#import "PFColorTransparentView.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation PFColorTransparentView

- (id)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

- (void)drawRect:(CGRect)rect {
    int kHeight = 20;
    int kWidth = 20;
    NSArray *colors = [NSArray arrayWithObjects:
                       [UIColor whiteColor],
                       [UIColor grayColor],
                       nil];
    for (int row = 0; row < rect.size.height; row += kHeight) {
        int index = row % (kHeight * 2) == 0 ? 0 : 1;
        for (int col = 0; col < rect.size.width; col += kWidth) {
            [[colors objectAtIndex:index++ % 2] setFill];
            UIRectFill(CGRectMake(col, row, kWidth, kHeight));
        }
    }
}

@end
