//
//  ColorViewController.h
//  UIColors
//
//  Created by Bailey Seymour on 1/23/14.
//
//
#import <UIKit/UIKit.h>
@class PSViewController;
@interface PFColorViewController : PSViewController

- (id)initForContentSize:(CGSize)size;
- (void)loadCustomViews;

@property (nonatomic, strong) NSString *defaults; //Required example: @"com.baileyseymour.test"
@property (nonatomic, strong) NSString *key; //Required example @"aColor"
@property (nonatomic, assign) BOOL usesRGB; //Default: false
@property (nonatomic, assign) BOOL usesAlpha; //Default: false
@property (nonatomic, strong) NSString *postNotification;
@property (nonatomic, strong) NSString *fallback;

@end