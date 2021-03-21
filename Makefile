ifdef SIMULATOR
TARGET = simulator:clang:11.2:8.0
else
	TARGET = iphone:clang:11.2:7.0
	ifneq ($(debug),0)
		ARCHS= arm64 arm64e
	else
		ARCHS= armv7 arm64 arm64e
	endif
endif

LIBRARY_NAME = libcolorpicker

libcolorpicker_FILES = libcolorpicker.mm UIColor+PFColor.m PFColorAlert.m PFColorAlertViewController.xm PFHaloHueView.m PFHaloKnobView.m PFColorLitePreviewView.m PFColorLiteSlider.m PFLiteColorCell.mm PFSimpleLiteColorCell.mm PFColorPickerWelcome.mm PFSimpleLiteColorCell_.mm
libcolorpicker_FRAMEWORKS = UIKit CoreGraphics Foundation Social Accounts
libcolorpicker_PRIVATE_FRAMEWORKS = Preferences
libcolorpicker_LDFLAGS += -Wl,-segalign,4000
libcolorpicker_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations
PFColorPickerWelcome.mm_CFLAGS = -Wno-deprecated-declarations

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/library.mk
ifdef SIMULATOR
include $(THEOS)/makefiles/locatesim.mk
endif

after-install::
	install.exec "killall -9 Preferences"

setup::
	@[ -f /usr/lib/$(LIBRARY_NAME).dylib ] || sudo ln -s $(PL_SIMJECT_ROOT)/usr/lib/$(LIBRARY_NAME).dylib /usr/lib/$(LIBRARY_NAME).dylib || true
	@[ -f /usr/lib/$(LIBRARY_NAME).dylib ] || echo -e "\x1b[1;35m>> warning: create symlink in /usr/lib yourself if needed\x1b[m" || true

remove:: 
	@sudo rm -f /usr/lib/$(LIBRARY_NAME).dylib
