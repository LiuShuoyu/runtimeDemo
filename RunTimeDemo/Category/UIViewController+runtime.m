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

@property (nonatomic, strong) NSDate *date; //viewDidAppear 的时间

@end
const  char *viewDidAppearTimeIntervalKey = "viewDidAppearTimeIntervalKey";


@implementation UIViewController (runtime)

+ (void)load
{
    SEL systemDidAppearSel = @selector(viewDidAppear:);
    SEL customDidAppearSel = @selector(swizzleViewDidAppear:);
    [UIViewController swizzleSystemSel:systemDidAppearSel implementationCustomSel:customDidAppearSel];
    
    SEL sysDidDisappearSel =@selector(viewDidDisappear:);
    SEL customwDidDisappearSel =@selector(swizzleViewDidDisappear:);
    [UIViewController swizzleSystemSel:sysDidDisappearSel implementationCustomSel:customwDidDisappearSel];
    
    
    
    
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
    NSLog(@" class =%@ 访问一次 在这里实现用户统计用埋点\n",[self class] );
    
    [self setDate:[NSDate new]];
    NSLog(@"访问时间 ＝%@",[self date]);
    
    [self swizzleViewDidAppear:animated];
}


- (void)swizzleViewDidDisappear:(BOOL )animated
{
    [self swizzleViewDidDisappear:animated];
    NSDate  *date=[NSDate new];
    NSLog(@"访问时间%@  离开时间＝%@ \n ", date,self.date);
    NSLog(@" %@访问时间TimeInterval ＝%f秒", [self class],[date timeIntervalSinceDate:self.date]);
    
}

- (NSDate *)date
{
    return  objc_getAssociatedObject(self, viewDidAppearTimeIntervalKey);
}

- (void)setDate:(NSDate *)date
{
    objc_setAssociatedObject(self, viewDidAppearTimeIntervalKey, date, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end

