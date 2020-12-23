#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "libcolorpicker.h"
#import "PSSpecifier.h"

@interface PFSimpleLiteColorCell()
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, retain) PFColorAlert *alert;
@end

#define kKey @"key"
#define kDefaults @"defaults"
#define kAlpha @"alpha"
#define kFallback @"fallback"

@implementation PFSimpleLiteColorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    [self setLCPOptions];

    return self;
}

- (void)setLCPOptions {
    [[self.specifier properties] addEntriesFromDictionary:[self.specifier properties][@"libcolorpicker"]];

    self.options = [[self.specifier properties][@"libcolorpicker"] mutableCopy];
    if (!self.options) self.options = [NSMutableDictionary dictionary];
}

- (UIColor *)previewColor {
    if(!self.specifier) return [UIColor clearColor];
    SEL sel=((PSSpecifier*)self.specifier)->getter;
    id target=[self viewController];
    if(!target ||![target respondsToSelector:sel]) return [UIColor clearColor];
    id value=((id (*)(id, SEL, id))[target methodForSelector:sel])(target, sel, self.specifier);
    return LCPParseColorString(value, self.options[kFallback]); // this color will be used at startup
}

- (void)openColorAlert {
    if (!self.options[kDefaults] || !self.options[kKey] || !self.options[kFallback])
        return;
    
    UIColor *startColor = [self previewColor]; // this color will be used at startup

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

        {
            SEL sel=((PSSpecifier*)self.specifier)->getter;
            id target=[self viewController];
            id value=((id (*)(id, SEL, id))[target methodForSelector:sel])(target, sel, self.specifier);
            if([value isEqualToString:hexString]) return;
        }
        
        SEL sel=((PSSpecifier*)self.specifier)->setter;
        id target=[self viewController];
        ((void (*)(id, SEL, id, id))[target methodForSelector:sel])(target, sel, hexString, self.specifier);
        [self updateCellDisplay];

    }];
}

- (void)didMoveToSuperview {
    [self setLCPOptions];

    [super didMoveToSuperview];

    [self.specifier setTarget:self];
    [self.specifier setButtonAction:@selector(openColorAlert)];
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

-(BOOL)canReload{
    return YES;
}

-(void)reloadWithSpecifier:(id)specifier animated:(BOOL)animated{
    [self updateCellDisplay];
}

- (id)viewController{
    id ret=self;
    while((ret=[ret nextResponder])){
        if([ret isKindOfClass:[UIViewController class]]) return ret;
    }
    return nil;
}
@end
