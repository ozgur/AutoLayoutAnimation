//
//  UIViewController+Accessibility.m
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/2/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

#import "UIViewController+Accessibility.h"
#import "IvarAccess.h"
#import "NSObject+Swizzler.h"
#import <objc/runtime.h>

@implementation UIViewController (Accessibility)

+ (void)load
{
  [super load];
  
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    [self swizzleInstanceMethod:@selector(viewWillAppear:) withMethod:@selector(accessibility_aware_viewWillAppear:)];
  });
}

- (void)accessibility_aware_viewWillAppear:(BOOL)animated
{
  [self accessibility_aware_viewWillAppear:animated];
  
  unsigned int variableCount = 0;
  Ivar *variables = class_copyIvarList(self.class, &variableCount);
  for (NSUInteger i = 0; i < variableCount; i++) {
    NSString *variableName = [NSString stringWithCString:ivar_getName(variables[i]) encoding:NSUTF8StringEncoding];
    
    if ([variableName hasPrefix:@"_"]) {
      continue;
    }
    Class klass = ivar_getObjectTypeSwift(variables[i], self.class);
    if (klass) {
      id variableValue = object_getIvar(self, variables[i]);
      if ([variableValue isKindOfClass:[UIView class]]) {
        UIView *v = (UIView *)variableValue;
        NSString *className = [[NSStringFromClass(self.class) componentsSeparatedByString:@"."] lastObject];
        v.accessibilityIdentifier = [NSString stringWithFormat:@"%@.%@", className, variableName];
      }
    }
  }
  free(variables);
}

@end