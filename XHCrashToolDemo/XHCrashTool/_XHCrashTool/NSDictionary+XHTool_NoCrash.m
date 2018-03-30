//
//  NSDictionary+XHTool.m
//  crash
//
//  Created by xixixi on 16/12/16.
//  Copyright © 2016年 xixixi. All rights reserved.
//

#import "NSDictionary+XHTool_NoCrash.h"
#import <objc/runtime.h>
@implementation NSDictionary (XHTool)
+(void)load{
    [super load];
    //防止插入nil导致crash
    Method oldCreateObjc = class_getClassMethod(self, @selector(dictionaryWithObjects:forKeys:count:));
    Method newCreateObjc = class_getClassMethod(self, @selector(XHdictionaryWithObjects:forKeys:count:));
    method_exchangeImplementations(oldCreateObjc, newCreateObjc);
}

+ (instancetype)XHdictionaryWithObjects:(const id  [])objects forKeys:(const id [])keys count:(NSUInteger)cnt{
    //BOOL correct = YES;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < cnt; i++ ) {
        NSString *addr = [NSString stringWithFormat:@"%p",objects[i]];
        if ([addr length] <= 5) {
            [dic setValue:@"" forKey:keys[i]];
        }else{
            [dic setValue:objects[i] forKey:keys[i]];
        }
    }
    return dic.copy;
}

@end
