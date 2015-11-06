//
//  UIImage+Additions.h
//  AutoLayoutAnimation
//
//  Created by Ozgur Vatansever on 11/4/15.
//  Copyright © 2015 Techshed. All rights reserved.
//

@import UIKit;

@interface UIImage (Additions)

@property (nonatomic, strong, readonly) NSString *name;

/**
 *  Creates a new image with given size using the original image.

 *  Stretches or shrinks image's content with respect to widthScale/heightScale ratio.
 *  Works similar to UIViewContentModeScaleToFill content mode. No cropping occurs on the 
 *  resulting image whatsoever.
 *
 *  @param image   UIImage to be scaled
 *  @param newSize CGSize to fill it with image content as best as possible.
 *
 *  @return new Image with given size.
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaleAspectFitToSize:(CGSize)newSize;

/**
 *  Creates a new image with given size using the original image.
 *
 *  If `newSize.height` is less than `image.size.height`, image is cropped (trimmed)
 *  from top and bottom equally and centered on y-axis in order to fit into new size.
 *
 *  If `newSize.width` is less than `image.size.width`, image is cropped (trimmed)
 *  from left and right equally and centered on x-axis in order to fit into new size.
 *
 *  If image's size is less than given size, image is returned without any modification.
 *
 *  @param image   UIImage to be scaled
 *  @param newSize CGSize to fill it with image content as best as possible.
 *
 *  @return new Image with given size.
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaleAspectFillToSize:(CGSize)newSize;

/**
 *  Returns a scaled CGRect that maintains the aspect ratio specified by image's size within a bounding CGRect.
 *  This is useful when attempting to fit the image within the bounds of another rectangle.
 *  Calls `AVMakeRectWithAspectRatioInsideRect:` internally.
 */
- (CGRect)rectWithAspectRatioInsideRect:(CGRect)boundingRect;

@end
