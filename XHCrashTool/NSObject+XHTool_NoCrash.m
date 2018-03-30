//
//  NSObject+XHTool.m
//  JHCommunityClient_V3
//
//  Created by xixixi on 2017/12/14.
//  Copyright © 2017年 xixixi. All rights reserved.
//

#import "NSObject+XHTool_NoCrash.h"
#import <objc/runtime.h>
#import "ForwardingTarget.h"

static ForwardingTarget *_target = nil;

@implementation NSObject (DoesNotRecognizeSelectorExtension)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _target = [ForwardingTarget new];;
        not_recognize_selector_classMethodSwizzle([self class], @selector(forwardingTargetForSelector:), @selector(doesnot_recognize_selector_swizzleForwardingTargetForSelector:));
    });
}

+ (BOOL)isWhiteListClass:(Class)class {
//    NSString *classString = NSStringFromClass(class);
//    BOOL isInternal = [classString hasPrefix:@"_"];
//    if (isInternal) {
//        return NO;
//    }
//    BOOL isNull =  [classString isEqualToString:NSStringFromClass([NSNull class])];
//
//    BOOL isMyClass  = YES;
//    return isNull || isMyClass;
    return YES;
}

- (id)doesnot_recognize_selector_swizzleForwardingTargetForSelector:(SEL)aSelector {
    id result = [self doesnot_recognize_selector_swizzleForwardingTargetForSelector:aSelector];
    if (result) {
        return result;
    }
    //白名单
    BOOL isWhiteListClass = [[self class] isWhiteListClass:[self class]];
    if (!isWhiteListClass) {
        return nil;
    }
    
    if (!result) {
        result = _target;
    }
    return result;
}

#pragma mark - private method

BOOL not_recognize_selector_classMethodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector) {
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
    BOOL didAddMethod =
    class_addMethod(aClass,
                    originalSelector,
                    method_getImplementation(swizzleMethod),
                    method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    return YES;
}

@end

