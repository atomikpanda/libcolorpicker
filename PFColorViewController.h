//
//  ColorViewController.h
//  UIColors
//
//  Created by Bailey Seymour on 1/23/14.
//
//
#import <UIKit/UIKit.h>
@class PSViewController;
@interface PFColorViewController : UIViewController

- (id)initForContentSize:(CGSize)size;
// convenience initForContentSize:defaults:key:usesRGB:usesAlpha:postNotification:fallback:
- (id)initForContentSize:(CGSize)size defaults:(NSString *)cdefaults key:(NSString *)ckey usesRGB:(BOOL)cusesRGB usesAlpha:(BOOL)cusesAlpha postNotification:(NSString *)cpostNotification fallback:(NSString *)cfallback;
- (void)loadCustomViews;

@property (nonatomic, retain) NSString *defaults; //Required example: @"com.baileyseymour.test"
@property (nonatomic, retain) NSString *key; //Required example @"aColor"
@property (nonatomic, assign) BOOL usesRGB; //Default: false
@property (nonatomic, assign) BOOL usesAlpha; //Default: false
@property (nonatomic, retain) NSString *postNotification;
@property (nonatomic, retain) NSString *fallback;

@end
