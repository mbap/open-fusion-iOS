//
//  GSFOpenCvImageProcessor.m
//  GSFDataCollecter
//
//  Created by Michael Baptist on 1/29/14.
//  Copyright (c) 2014 Michael Baptist - LLNL. All rights reserved.
//

#import "GSFOpenCvImageProcessor.h"
#import "GSFData.h"
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/highgui/ios.h>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgproc/imgproc.hpp>

@interface GSFOpenCvImageProcessor ()

// convert image from UIImage to cvMat format to use the opencv framework.
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

// conver image from cvMat to UIImage for after the image is processed.
- (UIImage *)UIImageFromCvMat:(cv::Mat)cvMatImage;

@end

@implementation GSFOpenCvImageProcessor


// convert image from UIImage to cvMat format to use the opencv framework.
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    
    // notice that the cols and rows are swapped from the image.
    // this will prevent the 90 degree rotation after processing.
    CGFloat cols = image.size.height;
    CGFloat rows = image.size.width;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 3 channels (color channels) 1 alpha
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

// conver image from cvMat to UIImage for after the image is processed.
- (UIImage *)UIImageFromCvMat:(cv::Mat)cvMatImage;
{
    NSData *data = [NSData dataWithBytes:cvMatImage.data length:cvMatImage.elemSize()*cvMatImage.total()];
    CGColorSpaceRef colorref = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageref = CGImageCreate(cvMatImage.cols, cvMatImage.rows, 8, 8*cvMatImage.elemSize(), cvMatImage.step[0], colorref, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageref scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(imageref);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorref);
    
    return finalImage;
}

// detect people. currenly has mostly negative results.
- (NSMutableArray *)detectPeopleUsingImageArray:(NSMutableArray *)capturedImages
{
    NSMutableArray *processed = [[NSMutableArray alloc] init];
    cv::HOGDescriptor hog;
    hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
    
    for (GSFData *data in capturedImages) {
        cv::Mat matimg = [self cvMatFromUIImage:data.image];
        cv::vector<cv::Rect> found;
        cv::vector<cv::Rect> found_filtered;
        cv::Mat rgbMat(matimg.rows, matimg.cols, CV_8UC3); // 8 bits per component, 3 channels
        cvtColor(matimg, rgbMat, CV_RGBA2RGB, 3);
        hog.detectMultiScale(rgbMat, found, 0, cv::Size(8,8), cv::Size(32,32), 1.05, 2);
    
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
        UIImage *finalimage = [self UIImageFromCvMat:matimg];
        [processed addObject:finalimage];
    }
    return processed;
}

- (NSMutableArray* )detectFacesUsingImageArray:(NSMutableArray *)capturedImages
{
    NSMutableArray *processed = [[NSMutableArray alloc] init];
    for (GSFData *data in capturedImages) {
        cv::Mat matimg = [self cvMatFromUIImage:data.image];
        cv::Mat matgrey;
        cvtColor(matimg, matgrey, CV_BGR2GRAY);
        equalizeHist(matgrey, matgrey);
        cv::CascadeClassifier faceDetector;
        int x = faceDetector.load("haarcascade_frontalface_default.xml");
        if (!x) NSLog(@"cascade load error");
        //faceDetector.load("haarcascade_frontalface_alt.xml");

        cv::vector<cv::Rect> faces;
        //faceDetector.detectMultiScale(matgrey, faces, 1, 1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30,30)); // look into documentation more for param info.
        
        faceDetector.detectMultiScale(matgrey, faces);
        
        for(size_t i = 0; i < faces.size(); i++ ) {
            cv::Point center(faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5);
            cv::ellipse(matimg, center, cv::Size(faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar(255, 0, 255), 4, 8, 0);
        }
        [processed addObject:[self UIImageFromCvMat:matimg]];
    }
    return processed;
}


@end

