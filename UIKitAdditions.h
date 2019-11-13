@interface UIScene : NSObject
@end

@interface UIWindowScene
@property (nonatomic, retain) NSSet<UIWindow *> *windows;
@end

@interface UIWindow (NewiOSMethods)
-(instancetype) initWithWindowScene:(UIScene *)scene;
@end

@interface UIApplication (NewiOSMethods)
-(id)connectedScenes;
@end