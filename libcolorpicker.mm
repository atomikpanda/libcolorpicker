#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import <iostream>
#import <string>
#import <vector>

int convertFromHex(std::string hex) {
    int value = 0;

    int a = 0;
    int b = ((int)hex.length()) - 1;

    for (; b >= 0; a++, b--) {
        if (hex[b] >= '0' && hex[b] <= '9')
            value += (hex[b] - '0') * (1 << (a * 4));
        else {
            switch (hex[b]) {
                case 'A':
                case 'a':
                    value += 10 * (1 << (a * 4));
                    break;

                case 'B':
                case 'b':
                    value += 11 * (1 << (a * 4));
                    break;

                case 'C':
                case 'c':
                    value += 12 * (1 << (a * 4));
                    break;

                case 'D':
                case 'd':
                    value += 13 * (1 << (a * 4));
                    break;

                case 'E':
                case 'e':
                    value += 14 * (1 << (a * 4));
                    break;

                case 'F':
                case 'f':
                    value += 15 * (1 << (a * 4));
                    break;

                default:
                    NSLog(@"Error, invalid char '%d' in hex number", hex[a]);
                    break;
            }
        }
    }

    return value;
}


void hextodec(std::string hex, std::vector<unsigned char>& rgb) {
    // since there is no prefix attached to hex, use this code
    int prefix_len = 0;
    std::string redString = hex.substr(0 + prefix_len, 2);
    std::string greenString = hex.substr(2 + prefix_len, 2);
    std::string blueString = hex.substr(4 + prefix_len, 2);

    /*
        if the prefix # was attached to hex, use the following code
        string redString = hex.substr(1, 2);
        string greenString = hex.substr(3, 2);
        string blueString = hex.substr(5, 2);
     */

    unsigned char red = (unsigned char)(convertFromHex(redString));
    unsigned char green = (unsigned char)(convertFromHex(greenString));
    unsigned char blue = (unsigned char)(convertFromHex(blueString));

    rgb[0] = red;
    rgb[1] = green;
    rgb[2] = blue;
}

extern "C" UIColor *colorFromHex(NSString *hexString);
extern "C" UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);
extern "C" UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback);

UIColor *colorFromHex(NSString *hexString) {
    if (hexString.length > 0) {
        if ([hexString hasPrefix:@"#"])
            hexString = [hexString substringFromIndex:1];

        std::string hexColor;

        std::vector<unsigned char> rgbColor(3);
        hexColor = hexString.UTF8String;

        if (hexColor.length() != 6) {
            std::string sixDigitHexColor = "";
            for (int i = 0; 6 > i; i++) {
                switch (i) {
                    case 0:
                        sixDigitHexColor.append(hexColor.substr(i, 1));
                        sixDigitHexColor.append(hexColor.substr(i, 1));
                        break;

                    case 1:
                        sixDigitHexColor.append(hexColor.substr(i, 1));
                        sixDigitHexColor.append(hexColor.substr(i, 1));
                        break;

                    case 2:
                        sixDigitHexColor.append(hexColor.substr(i, 1));
                        sixDigitHexColor.append(hexColor.substr(i, 1));
                        break;

                    default:
                        break;
                }
            }

            hexColor = sixDigitHexColor;
        }

        hextodec(hexColor, rgbColor);
        return [UIColor colorWithRed:int(rgbColor[0]) / 255.f
                               green:int(rgbColor[1]) / 255.f
                                blue:int(rgbColor[2]) / 255.f
                               alpha:1];
    } else { // Random
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    }
}

// do not use this method anymore
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback) {
    NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaults]];
    //fallback
    UIColor *fallbackColor = colorFromHex(fallback);
    CGFloat currentAlpha = 1.0f;

    if (preferencesPlist && [preferencesPlist objectForKey:key]) {
        NSString *value = [preferencesPlist objectForKey:key];
        NSArray *colorAndOrAlpha = [value componentsSeparatedByString:@":"];
        if ([value rangeOfString:@":"].location != NSNotFound) {
            if ([colorAndOrAlpha objectAtIndex:1])
                currentAlpha = [colorAndOrAlpha[1] floatValue];
            else
                currentAlpha = 1;
        }

        if (!value)
            return fallbackColor;

        NSString *color = colorAndOrAlpha[0];

        return [colorFromHex(color) colorWithAlphaComponent:currentAlpha];
    } else {
        return fallbackColor;
    }
}

UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback) {
    //fallback
    UIColor *fallbackColor = colorFromHex(colorStringFallback);
    CGFloat currentAlpha = 1.0f;

    if (colorStringFromPrefs && colorStringFromPrefs.length > 0) {
        NSString *value = colorStringFromPrefs;
        if (!value || value.length == 0)
            return fallbackColor;

        NSArray *colorAndOrAlpha = [value componentsSeparatedByString:@":"];
        if ([value rangeOfString:@":"].location != NSNotFound) {
            if ([colorAndOrAlpha objectAtIndex:1])
                currentAlpha = [colorAndOrAlpha[1] floatValue];
            else
                currentAlpha = 1.0f;
        }

        if (!value)
            return fallbackColor;

        NSString *color = colorAndOrAlpha[0];
        return [colorFromHex(color) colorWithAlphaComponent:currentAlpha];
    } else {
        return fallbackColor;
    }
}
