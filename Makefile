ifdef SIMULATOR
TARGET = simulator:clang:11.2:9.0
ARCHS = x86_64
else
	TARGET = iphone:clang:11.2:7.0
	ifneq ($(debug),0)
		ARCHS= arm64 arm64e
	else
		ARCHS= armv7 arm64 arm64e
	endif
endif



ifdef SIMULATOR
LIBRARY_NAME = libcolorpicker-sim
else
LIBRARY_NAME = libcolorpicker
endif


$(LIBRARY_NAME)_FILES = libcolorpicker.mm UIColor+PFColor.m PFColorAlert.m PFColorAlertViewController.xm PFHaloHueView.m PFHaloKnobView.m PFColorLitePreviewView.m PFColorLiteSlider.m PFLiteColorCell.mm PFSimpleLiteColorCell.mm PFColorPickerWelcome.mm QMDLPFSimpleLiteColorCell.mm
$(LIBRARY_NAME)_FRAMEWORKS = UIKit CoreGraphics Foundation Social Accounts
$(LIBRARY_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(LIBRARY_NAME)_LDFLAGS += -Wl,-segalign,4000
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations
PFColorPickerWelcome.mm_CFLAGS = -Wno-deprecated-declarations

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/library.mk
ifdef SIMULATOR
include $(THEOS)/makefiles/locatesim.mk
endif

after-install::
	install.exec "killall -9 Preferences"

	
ifneq (,$(filter x86_64 i386,$(ARCHS)))
setup:: all
	@[ -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_BUNDLES_PATH)
	@[ -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo mkdir -p $(PL_SIMULATOR_PLISTS_PATH)
	@[ -d $(PL_SIMULATOR_ROOT)/usr/lib ] || sudo mkdir -p $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib $(PL_SIMULATOR_ROOT)/usr/lib
	@sudo codesign -f -s - $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@sudo ln -s $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib /usr/lib/$(LIBRARY_NAME).dylib ||true
	@resim 
endif

remove:: 
	@[ ! -d $(PL_SIMULATOR_BUNDLES_PATH) ] || sudo rm -r $(PL_SIMULATOR_BUNDLES_PATH)
	@[ ! -d $(PL_SIMULATOR_PLISTS_PATH) ] || sudo rm -r $(PL_SIMULATOR_PLISTS_PATH)
	@sudo rm -f $(PL_SIMULATOR_ROOT)/usr/lib/$(LIBRARY_NAME).dylib
	@resim 
