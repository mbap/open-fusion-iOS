//
//  GSFOpenCvImageProcessor.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/29/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCvImageProcessor.h"
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/objdetect/objdetect.hpp>

@interface GSFOpenCvImageProcessor ()

// convert image from UIImage to cvMat format to use the opencv framework.
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

// conver image from cvMat to UIImage for after the image is processed.
+ (UIImage *)UIImageFromCvMat:(cv::Mat)cvMatImage;

@end

@implementation GSFOpenCvImageProcessor

// convert image from UIImage to cvMat format to use the opencv framework.
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
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
+ (UIImage *)UIImageFromCvMat:(cv::Mat)cvMatImage;
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

- (NSMutableArray *)detectPeopleUsingImageArray:(NSMutableArray *)capturedImages
{
    NSMutableArray *processed = [[NSMutableArray alloc] init];
    cv::HOGDescriptor hog;
    hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
    
    for (UIImage *img in capturedImages) {
        cv::Mat matimg = [GSFOpenCvImageProcessor cvMatFromUIImage:img];
        cv::vector<cv::Rect> found;
        cv::vector<cv::Rect> found_filtered;
        hog.detectMultiScale(matimg, found, 0, cv::Size(8,8), cv::Size(32,32), 1.05, 2);
    
    
        size_t i, j;
        for (i = 0; i < found.size(); i++)
        {
            cv::Rect r = found[i];
            for (j = 0; j < found.size(); j++)
                if (j != i && (r & found[j]) == r)
                    break;
            if (j == found.size())
                found_filtered.push_back(r);
        }
        for (i = 0; i < found_filtered.size(); i++)
        {
            cv::Rect r = found_filtered[i];
            r.x += cvRound(r.width*0.1);
	        r.width = cvRound(r.width*0.8);
    	    r.y += cvRound(r.height*0.06);
	        r.height = cvRound(r.height*0.9);
            cv::rectangle(matimg, r.tl(), r.br(), cv::Scalar(0,255,0), 2);
	    }
        UIImage *finalimage = [GSFOpenCvImageProcessor UIImageFromCvMat:matimg];
        [processed addObject:finalimage];
    }
    return processed;
}



@end

