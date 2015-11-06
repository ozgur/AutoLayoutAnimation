//
//  NSObject+Swizzler.h
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/4/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

@import Foundation;

@interface NSObject (Swizzler)

/**
 *  Swaps given instance methods on the class.
 *
 *  @param originalMethod original method with SEL type to be replaced
 *  @param anotherMethod method to replace the original method
 */
+ (void)swizzleInstanceMethod:(SEL)originalMethod withMethod:(SEL)anotherMethod;

/**
 *  Swaps given class methods on the class.
 *
 *  @param originalMethod original method with SEL type to be replaced
 *  @param anotherMethod method to replace the original method
 */
+ (void)swizzleClassMethod:(SEL)originalMethod withMethod:(SEL)anotherMethod;

@end
