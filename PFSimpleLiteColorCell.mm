#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "libcolorpicker.h"
#import "PSSpecifier.h"

@interface PFSimpleLiteColorCell()
- (void)openColorAlert;
@property (nonatomic, retain) NSMutableDictionary *options;
@end

@implementation PFSimpleLiteColorCell

@synthesize options;

- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    [self setLCPOptions];

    return self;
}

- (void)setLCPOptions {
    self.options = [[self.specifier properties] objectForKey:@"libcolorpicker"] ?
                   [[self.specifier properties] objectForKey:@"libcolorpicker"] :
                   [NSMutableDictionary dictionary];

    if (!self.options[@"PostNotification"]) {
        NSString *option = [NSString stringWithFormat:@"%@_%@_libcolorpicker_refreshn",
                                                          self.options[@"defaults"], self.options[@"key"]];
        [self.options setObject:option forKey:@"PostNotification"];
    }

    [(PSSpecifier *)self.specifier setProperty:self.options[@"PostNotification"] forKey:@"NotificationListener"];
}

- (UIColor *)previewColor {
    NSString *plistPath =  [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.options[@"defaults"]];

    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!prefsDict)
        prefsDict = [NSMutableDictionary dictionary];

    UIColor *color = LCPParseColorString([prefsDict objectForKey:self.options[@"key"]], self.options[@"fallback"]); // this color will be used at startup

    return color;
}

- (void)didMoveToSuperview {
    [self setLCPOptions];

    [super didMoveToSuperview];

    [self.specifier setTarget:self];
    [self.specifier setButtonAction:@selector(openColorAlert)];
}

- (void)openColorAlert {
    if (!self.options[@"defaults"] || !self.options[@"key"] || !self.options[@"fallback"])
    return;

    NSLog(@"::::::::: %@", self.options);

    NSString *plistPath =  [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.options[@"defaults"]];

    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!prefsDict)
        prefsDict = [NSMutableDictionary dictionary];

    UIColor *startColor = LCPParseColorString([prefsDict objectForKey:self.options[@"key"]], self.options[@"fallback"]); // this color will be used at startup
    PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:startColor
                                                       showAlpha:self.options[@"alpha"] ? [self.options[@"alpha"] boolValue] : NO
    ];

    // show alert                               // Show alpha slider? // Code to run after close
    [alert displayWithCompletion:
    ^void (UIColor *pickedColor) {
        // save pickedColor or do something with it
        NSString *hexString = [UIColor hexFromColor:pickedColor];
        hexString = [hexString stringByAppendingFormat:@":%f", pickedColor.alpha]; //if you want to use alpha
        //                                                                                                                              ^^ parse fallback to ^red
        // save hexString to your plist if desired

        [prefsDict setObject:hexString forKey:self.options[@"key"]];

        [prefsDict writeToFile:plistPath atomically:YES];

        if (self.options[@"PostNotification"])
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                        (CFStringRef) self.options[@"PostNotification"],
                        (CFStringRef) self.options[@"PostNotification"],
                        NULL,
                        YES);
    }];
}

- (void)dealloc {
    self.options = nil;
    [super dealloc];
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
