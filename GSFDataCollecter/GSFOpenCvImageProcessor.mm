//
//  GSFOpenCvImageProcessor.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/29/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCvImageProcessor.h"

@implementation GSFOpenCvImageProcessor

// convert image from UIImage to cvMat format to use the opencv framework.
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorref = CGImageGetColorSpace(image.CGImage); // get color space for bitmap image.
    CGFloat row = image.size.width;
    CGFloat col = image.size.height;
    
    cv::Mat cvMat(row, col, CV_8UC4);  // not exactly sure how this works.
                                       // i do know it is using CV_8UC4 format which
                                       // specifies 8u bits per component. with 3 colors and alpha channel (colorimage)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data, row, col, 8, cvMat.step[0], colorref, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, col, row), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

// conver image from cvMat to UIImage for after the image is processed.
- (UIImage *)UIImageFromCvMat:(cv::Mat)cvMatImage;
{
    NSData *data = [NSData dataWithBytes:cvMatImage.data length:cvMatImage.elemSize()*cvMatImage.total()];
    CGColorSpaceRef colorref = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageref = CGImageCreate(cvMatImage.cols, cvMatImage.rows, 8, 8*cvMatImage.elemSize(), cvMatImage.step[0], colorref, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageref];
    CGImageRelease(imageref);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorref);
    
    return finalImage;
}


@end
