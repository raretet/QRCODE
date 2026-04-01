#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "onboarding1" asset catalog image resource.
static NSString * const ACImageNameOnboarding1 AC_SWIFT_PRIVATE = @"onboarding1";

/// The "onboarding2" asset catalog image resource.
static NSString * const ACImageNameOnboarding2 AC_SWIFT_PRIVATE = @"onboarding2";

#undef AC_SWIFT_PRIVATE
