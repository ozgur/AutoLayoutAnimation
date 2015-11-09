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

- (BOOL)assignedAllAccessibilityIdentifiersForInstanceVariables
{
  return [objc_getAssociatedObject(self, @selector(assignedAllAccessibilityIdentifiersForInstanceVariables)) boolValue];
}

- (void)setAssignedAllAccessibilityIdentifiersForInstanceVariables:(BOOL)assignedAllAccessibilityIdentifiersForInstanceVariables
{
  objc_setAssociatedObject(self,
                           @selector(assignedAllAccessibilityIdentifiersForInstanceVariables),
                           @(assignedAllAccessibilityIdentifiersForInstanceVariables), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
  
  if (!self.assignedAllAccessibilityIdentifiersForInstanceVariables) {
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
          v.accessibilityIdentifier = [self designatedAccessibilityIdentifierForInstanceVariable:variableName];
        }
      }
    }
    free(variables);
    
    self.assignedAllAccessibilityIdentifiersForInstanceVariables = YES;
  }
}

- (NSString *)designatedAccessibilityIdentifierForInstanceVariable:(nonnull NSString *)ivarName
{
  NSString *className = [[NSStringFromClass(self.class) componentsSeparatedByString:@"."] lastObject];
  return [NSString stringWithFormat:@"%@.%@", className, ivarName];
}

@end