# libcolorpicker

# The new libcolorpicker:

The new libcolorpicker `PFColorAlert` is focused on being lightweight, portable, and easy to use.
#### How to implement:

* Search and install **the latest** __libcolorpicker__ from Cydia.

* Copy __/usr/lib/libcolorpicker.dylib__ from your iOS device to your __$THEOS/lib__ folder.

* Add `TWEAKNAME_LIBRARIES = colorpicker` to your Tweak's Makefile if needed

*  Add  `TWEAKNAMEPREFS_LIBRARIES = colorpicker` to your Pref's Makefile if needed

* Download libcolorpicker.h from the root of this git and place in __$THEOS/include__ folder.

##### Showing the alert:
```objc
PFColorAlert *alert = [[[PFColorAlert alloc] init] autorelease]; // init

	UIColor *startColor = [UIColor colorWithRed:0.769  green:0.286  blue:0.008 alpha:0.75]; // this color will be used at startup
	// show alert                               // Show alpha slider? // Code to run after close
	[liteColor showWithStartColor:startColor showAlpha:YES completion:
	^void (UIColor *pickedColor){
		// save pickedColor or do something with it
		NSString *hexString = LCPParseColorString([UIColor hexFromColor:pickedColor], @"#ff0000");
		// 																																^^ parse fallback to ^red
		// save hexString to your plist if desired
	}];
```
##### Reading saved color later on (From Tweak):
```objc
NSDictionary *prefsDict = ... // assuming this holds your prefs
NSString *coolColorHex = [prefsDict objectForKey:@"someCoolKey"]; // assuming that the key has a value saved using LCPParseColorString()

UIColor *coolColor = LCPParseColorString(coolColorHex, @"#ff0000"); // fallback to red (#ff0000)
// do something with coolColor
```

![screen shot](https://pbs.twimg.com/media/CKKQ1OqWoAAF7_W.png:large)

# The old libcolorpicker:

_libcolorpicker is a iOS library that provides an easy to implement Color Picker.
Here are some of it's main features:_

* iPhone & iPad Compatible
* HSB touch color picker
* Option to Use HSB or RGB sliders
* Option for color transparency/opacity/alpha
* No images or "extra components" just the library
* Post settings changed notifications on save (Optional)
* Enter a hex color or copy one to your clipboard
* Made for iOS 7 & 8, Compatible with iOS 6
* Saves colors instantly to your preferences plist
* iPhone 3.5 inch & 4inch screen compatibility
* Open source

How to add libcolorpicker into your tweak:

First add a this into your Tweaks Preferences specifier plist and modify to your liking:

			<dict>
                <key>cell</key>
                <string>PSLinkCell</string>
                <key>cellClass</key>
                <string>PFColorCell</string>
                <key>label</key>
                <string>A Color</string>
                <key>color_defaults</key>
                <string>com.yourcompany.tweak</string>
                <key>color_key</key>
                <string>aColor</string>
                <key>title</key>
                <string>A Color</string>
                <key>color_fallback</key>
                <string>#10b6ec</string>
				<key>usesRGB</key>
				<false/>
				<key>usesAlpha</key>
				<true/>
                <key>color_postNotification</key>
                <string>com.yourcompany.tweak.settingschanged</string>
            </dict>

## Using Version on BigBoss (Recommended)
* Search and install __libcolorpicker__ from Cydia.

* Copy __/usr/lib/libcolorpicker.dylib__ from your iOS device to your __$THEOS/lib__ folder.

* Add `TWEAKNAME_LIBRARIES = colorpicker` to your Tweak's Makefile

*  Add  `TWEAKNAMEPREFS_LIBRARIES = colorpicker` to your Pref's Makefile

* Next
 Add the following to to your Preference Bundle's `PSListController @implementation`

		- (void)viewWillAppear:(BOOL)animated
		{
  	  		[self clearCache];
 	 		  [self reload];  
   			 [super viewWillAppear:animated];
		}

-------------

PLEASE DO NOT DO THIS :P
It will result in loading different versions of libcolorpicker.

## Using Custom Build

Next, Place the libcolorpicker.dylib in TweakPreferencesFolder/lib/

Next, Add the following to your Preference Bundle's Makefile:

		$(shell install_name_tool -id /usr/lib/libcolorpicker_PUTTWEAKNAMEHERE.dylib lib/libcolorpicker.dylib)

		TWEAKNAMEPREFERENCES_LDFLAGS = -Llib -lcolorpicker

		include $(THEOS_MAKE_PATH)/bundle.mk

		internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/lib/$(ECHO_END)
	$(ECHO_NOTHING)cp lib/libcolorpicker.dylib $(THEOS_STAGING_DIR)/usr/lib/libcolorpicker_PUTTWEAKNAMEHERE.dylib$(ECHO_END)


Next, Add the following to to your Preference Bundle's PSListController @implementation:

	- (void)viewWillAppear:(BOOL)animated
	{
    [self clearCache];
    [self reload];  
    [super viewWillAppear:animated];
	}

## Getting the color from the plist:

To get the color from your tweak you can use the `UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback)` function found in __libcolorpicker.mm__

First you need to define the function in your header (.h) file:
`UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);`

An example on how to use it would be:
	`UIColor *someColor = colorFromDefaultsWithKey(@"com.example.tweak", @"someColor", @"#ffffff");`

This would fallback to white *(#ffffff)* if the color is `nil`;


## Example Tweak to change UILabel text's color and shadow: ##
[https://bitbucket.org/rob311/pflibcolorpickerexample](https://bitbucket.org/rob311/pflibcolorpickerexample)

__Check out the screen shots below__

![iOS Simulator Screen shot Aug 27, 2014, 3.49.02 PM.png](https://bitbucket.org/repo/poAx5p/images/3203715933-iOS%20Simulator%20Screen%20shot%20Aug%2027,%202014,%203.49.02%20PM.png)![iOS Simulator Screen shot Aug 27, 2014, 3.55.09 PM.png](https://bitbucket.org/repo/poAx5p/images/3068646252-iOS%20Simulator%20Screen%20shot%20Aug%2027,%202014,%203.55.09%20PM.png)

# License

The MIT License (MIT)

Copyright (c) 2014 PixelFireDev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

