//
//  ColorViewController.h
//  UIColors
//
//  Created by Bailey Seymour on 1/23/14.
//
//

#import <UIKit/UIKit.h>
@class PFColorTransparentView, PFColorPicker;
@protocol PFColorPickerDelegate;

@interface PFColorViewController : UIViewController <PFColorPickerDelegate, UIAlertViewDelegate>
{
    //HSB
    UISlider *hueSlider;
    UISlider *saturationSlider;
    UISlider *brightnessSlider;
    UISlider *alphaSlider;
    
    UIView *controlsContainer;
    PFColorTransparentView *transparent;
    
    CGFloat currentAlpha;
}

@property (nonatomic, strong) PFColorPicker *colorPicker;
@property (nonatomic, assign) NSString *defaults; //Required example: @"com.baileyseymour.test"
@property (nonatomic, assign) NSString *key; //Required example @"aColor"
@property (nonatomic, assign) BOOL usesRGB; //Default: false
@property (nonatomic, assign) BOOL usesAlpha; //Default: false
@property (nonatomic, assign) NSString *postNotification;

@end