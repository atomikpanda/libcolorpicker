//
//  ColorPicker.h
//  ColorPicker
//
//  Created by Bailey Seymour on 3/16/14.
//  Copyright (c) 2011 Bailey Seymour All rights reserved.
//
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface PFColorPicker : UIView
{
	BOOL shouldSaveNewCache;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly, retain) UIColor *lastSelectedColor;

- (id)initWithFrame:(CGRect)frame;
- (void)makeReadyForDisplay;
- (void)saveCache;
@end


@protocol PFColorPickerDelegate <NSObject>
- (void)pickedColor:(UIColor *)color;
@end
#endif