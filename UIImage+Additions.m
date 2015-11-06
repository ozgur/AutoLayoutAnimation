//
//  UIImage+Additions.m
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/4/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

#import "UIImage+Additions.h"
#import "NSObject+Swizzler.h"

@import AVFoundation;

@implementation UIImage (Additions)

#pragma mark - Naming UIImage

+ (void)load
{
  [super load];
  
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    [self swizzleClassMethod:@selector(imageNamed:) withMethod:@selector(name_aware_imageNamed:)];
    [self swizzleClassMethod:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)
                  withMethod:@selector(name_aware_imageNamed:inBundle:compatibleWithTraitCollection:)];

  });
}

+ (nullable UIImage *)name_aware_imageNamed:(NSString *)name
{
  UIImage *image = [self name_aware_imageNamed:name];
  image.accessibilityIdentifier = name;
  return image;
}

+ (nullable UIImage *)name_aware_imageNamed:(NSString *)name
                                   inBundle:(NSBundle *)bundle
              compatibleWithTraitCollection:(UITraitCollection *)traitCollection
{
  UIImage *image = [self name_aware_imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
  image.accessibilityIdentifier = name;
  return image;
}

- (nullable NSString *)name
{
  return self.accessibilityIdentifier;
}

#pragma mark - Scaling UIImage

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize inRect:(CGRect)rect
{
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  
  [image drawInRect:rect];
  UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return drawnImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaleAspectFitToSize:(CGSize)newSize
{
  if (image.size.width < newSize.width && image.size.height < newSize.height) {
    return [image copy];
  }
  
  CGFloat widthScale = newSize.width / image.size.width;
  CGFloat heightScale = newSize.height / image.size.height;
  CGFloat scaleFactor = MIN(widthScale, heightScale);
  
  CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
  CGRect scaledRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);

  return [UIImage imageWithImage:image scaledToSize:scaledSize inRect:scaledRect];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaleAspectFillToSize:(CGSize)newSize
{
  if (image.size.width < newSize.width && image.size.height < newSize.height) {
    return [image copy];
  }
  
  CGFloat widthScale = newSize.width / image.size.width;
  CGFloat heightScale = newSize.height / image.size.height;
  CGFloat scaleFactor = MAX(widthScale, heightScale);
  
  CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
  CGPoint imageDrawOrigin = CGPointMake(0, 0);
  if (widthScale > heightScale) {
    imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5;
  }
  else {
    imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5;
  }
  
  CGRect imageDrawRect = CGRectMake(imageDrawOrigin.x, imageDrawOrigin.y, scaledSize.width, scaledSize.height);
  return [UIImage imageWithImage:image scaledToSize:newSize inRect:imageDrawRect];
}

- (CGRect)rectWithAspectRatioInsideRect:(CGRect)boundingRect
{
  return AVMakeRectWithAspectRatioInsideRect(self.size, boundingRect);
}

@end
