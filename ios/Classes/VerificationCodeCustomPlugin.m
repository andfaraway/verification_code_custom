#import "VerificationCodeCustomPlugin.h"
#if __has_include(<verification_code_custom/verification_code_custom-Swift.h>)
#import <verification_code_custom/verification_code_custom-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "verification_code_custom-Swift.h"
#endif

@implementation VerificationCodeCustomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVerificationCodeCustomPlugin registerWithRegistrar:registrar];
}
@end
