//
//  NSArray+XHTool.m
//  crash
//
//  Created by xixixi on 16/12/16.
//  Copyright © 2016年 xixixi. All rights reserved.
//

#import "NSArray+XHTool_NoCrash.h"
#import <objc/runtime.h>
@implementation NSArray (XHTool_NoCrash)

+(void)load{
    [super load];
    //防止数组越界
    Method oldGetObjc1 = class_getInstanceMethod(self, @selector(objectAtIndexedSubscript:));
    Method newGetObjc1 = class_getInstanceMethod(self, @selector(XHObjectAtIndexedSubscript:));
    
    Method oldGetObjc2 = class_getClassMethod(self, @selector(arrayWithObjects:count:));
    Method newGetObjc2 = class_getClassMethod(self, @selector(XHArrayWithObjects:count:));
     /**
     *  我们在这里使用class_addMethod()函数对Method Swizzling做了一层验证，如果self没有实现被交换的方法，会导致失败。
     *  而且self没有交换的方法实现，但是父类有这个方法，这样就会调用父类的方法，结果就不是我们想要的结果了。
     *  所以我们在这里通过class_addMethod()的验证，如果self实现了这个方法，class_addMethod()函数将会返回NO，我们就可以对其进行交换了。
     */
    if (!class_addMethod([self class], @selector(objectAtIndexedSubscript:), method_getImplementation(newGetObjc1), method_getTypeEncoding(newGetObjc1))) {
        method_exchangeImplementations(oldGetObjc1, newGetObjc1);
    }
    method_exchangeImplementations(oldGetObjc2, newGetObjc2);
}

- (id)XHObjectAtIndexedSubscript:(NSUInteger)idx{
    //判断是否越界
    if (idx >= self.count ) {
//        if (self.count > 0) {
//            id objfirst = [self XHObjectAtIndexedSubscript:0];
//            return [[[objfirst class] alloc] init];
//        }
//        return @"";
        return nil; //对所有方法执行
    }else{
       return  [self XHObjectAtIndexedSubscript:idx];
    }
}
+ (NSArray *)XHArrayWithObjects:(const id [])obj count:(NSUInteger)cnt{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    id class_type;
    for (int i = 0; i < cnt; i++) {
        if(obj[i]){
            class_type = [obj[i] class];
            break;
        }
    }
    for (int i = 0; i < cnt; i++ ) {
        NSString *addr = [NSString stringWithFormat:@"%p",obj[i]];
        if ([addr length] <= 5) {
            if (class_type) {
                [arr addObject:[[class_type alloc] init]];
            }else{
                [arr addObject:@""];
            }
        }else{
            if (obj[i]) {
                [arr addObject:obj[i]];
            }
        }
    }
    return arr.copy;
}
@end
