//
//  NSObject+Swizzler.m
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/4/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

#import "NSObject+Swizzler.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzler)

+ (void)swizzleInstanceMethod:(SEL)originalMethod withMethod:(SEL)anotherMethod
{
  Method original = class_getInstanceMethod(self, originalMethod);
  Method another = class_getInstanceMethod(self, anotherMethod);
  method_exchangeImplementations(original, another);
}

+ (void)swizzleClassMethod:(SEL)originalMethod withMethod:(SEL)anotherMethod
{
  Method original = class_getClassMethod(self, originalMethod);
  Method another = class_getClassMethod(self, anotherMethod);
  method_exchangeImplementations(original, another);
}

@end
