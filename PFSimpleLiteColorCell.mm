#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "libcolorpicker.h"
#import "PSSpecifier.h"

@interface PFSimpleLiteColorCell()
- (void)openColorAlert;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, retain) PFColorAlert *alert;
@end

#define kPostNotification @"PostNotification"
#define kKey @"key"
#define kDefaults @"defaults"
#define kAlpha @"alpha"
#define kFallback @"fallback"

@implementation PFSimpleLiteColorCell

- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    [self setLCPOptions];

    return self;
}

- (void)setLCPOptions {
    self.options = [[self.specifier properties][@"libcolorpicker"] mutableCopy];
    if (!self.options)
        self.options = [NSMutableDictionary dictionary];

    if (!self.options[kPostNotification]) {
        NSString *option = [NSString stringWithFormat:@"%@_%@_libcolorpicker_refreshn",
                                                      self.options[kDefaults], self.options[kKey]];
        [self.options setObject:option forKey:kPostNotification];
    }

    [(PSSpecifier *)self.specifier setProperty:self.options[kPostNotification]
                                        forKey:@"NotificationListener"];
}

- (UIColor *)previewColor {
    NSString *plistPath =  [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.options[kDefaults]];

    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!prefsDict)
        prefsDict = [NSMutableDictionary dictionary];

    return LCPParseColorString([prefsDict objectForKey:self.options[kKey]], self.options[kFallback]); // this color will be used at startup
}

- (void)didMoveToSuperview {
    [self setLCPOptions];

    [super didMoveToSuperview];

    [self.specifier setTarget:self];
    [self.specifier setButtonAction:@selector(openColorAlert)];
}

- (void)openColorAlert {
    if (!self.options[kDefaults] || !self.options[kKey] || !self.options[kFallback])
        return;

    // HBLogDebug(@"Loading with options %@", self.options);

    NSString *plistPath =  [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.options[kDefaults]];

    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!prefsDict)
        prefsDict = [NSMutableDictionary dictionary];

    UIColor *startColor = LCPParseColorString([prefsDict objectForKey:self.options[kKey]], self.options[kFallback]); // this color will be used at startup
    BOOL showAlpha = self.options[kAlpha] ? [self.options[kAlpha] boolValue] : NO;
    self.alert = [PFColorAlert colorAlertWithStartColor:startColor
                                              showAlpha:showAlpha];

    // show alert                               // Show alpha slider? // Code to run after close
    [self.alert displayWithCompletion:^void (UIColor *pickedColor) {
        // save pickedColor or do something with it
        NSString *hexString = [UIColor hexFromColor:pickedColor];
        hexString = [hexString stringByAppendingFormat:@":%f", pickedColor.alpha]; //if you want to use alpha
        // ^^ parse fallback to ^red
        // save hexString to your plist if desired

        [prefsDict setObject:hexString forKey:self.options[kKey]];
        [prefsDict writeToFile:plistPath atomically:YES];

        NSString *notification = self.options[kPostNotification];
        if (notification)
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                            (CFStringRef)notification,
                            (CFStringRef)notification,
                            NULL,
                            YES);
    }];
}

- (SEL)action {
    return @selector(openColorAlert);
}

- (id)target {
    return self;
}

- (SEL)cellAction {
    return @selector(openColorAlert);
}

- (id)cellTarget {
    return self;
}

@end
