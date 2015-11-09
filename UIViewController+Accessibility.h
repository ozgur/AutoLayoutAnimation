//
//  UIViewController+Accessibility.h
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/2/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

@import UIKit;

@interface UIViewController (Accessibility)

@property (nonatomic, assign) BOOL assignedAllAccessibilityIdentifiersForInstanceVariables;

- (NSString *)designatedAccessibilityIdentifierForInstanceVariable:(NSString *)ivarName;

@end
