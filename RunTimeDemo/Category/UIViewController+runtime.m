//
//  UIViewController+runtime.m
//  runimeDemo
//
//  Created by lsy on 16/10/24.
//  Copyright © 2016年 zhixun. All rights reserved.
//

#import "UIViewController+runtime.h"
#import <objc/runtime.h>

@interface UIViewController ()


@end
const  NSString*visitCountKey = @"visitCountKey";


@implementation UIViewController (runtime)

+ (void)load
{
    SEL systemSel = @selector(viewDidAppear:);
    SEL customSel = @selector(swizzleViewDidAppear:);
    [UIViewController swizzleSystemSel:systemSel implementationCustomSel:customSel];
}

+ (void)swizzleSystemSel:(SEL)systemSel implementationCustomSel:(SEL)customSel
{
    Class cls = [self class];
    Method systemMethod =class_getInstanceMethod(cls, systemSel);
    Method customMethod =class_getInstanceMethod(cls, customSel);
    
    // BOOL class_addMethod(Class cls, SEL name, IMP imp,const char *types) cls被添加方法的类，name: 被增加Method的name, imp 被添加的Method的实现函数，types被添加Method的实现函数的返回类型和参数的字符串
    BOOL didAddMethod =class_addMethod(cls, systemSel, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
    if (didAddMethod)
    {
        class_replaceMethod(cls, customSel, method_getImplementation(systemMethod), method_getTypeEncoding(customMethod));
    }
    else
    {
        method_exchangeImplementations(systemMethod, customMethod);
    }
}

- (void)swizzleViewDidAppear:(BOOL )animated
{
    NSLog(@" class =%@ 访问一次  在这里实现用户访问用埋点",[self class] );
    [self swizzleViewDidAppear:animated];
}





@end

