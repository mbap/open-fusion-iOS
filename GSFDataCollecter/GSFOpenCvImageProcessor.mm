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

/**
 *  Converts an image taken from the iPhone into the cv::cvMat format so that the OpenCV framework can perform image processing on the cv::cvMat.
 *
 *  @param image The image to be converted into cv::cvMat.
 *
 *  @return The cv::cvMat data type from the UIImage passed in.
 */
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;

/**
 *  Converts an OpenCV cv::cvMat formatted image into an Apple UIImage to be used for iOS or OSX applications.
 *
 *  @param cvMatImage The cv::cvMat data type to be converted into an Apple UIImage.
 *
 *  @return A UIImage.
 */
- (UIImage *)UIImageFromCvMat:(cv::Mat)cvMatImage;

@end

@implementation GSFOpenCvImageProcessor

/**
 *  Rotates an image by a certain number of degrees. This has an effect on the bits of the image.
 *
 *  @param image   The image to be rotated.
 *  @param degrees The number in degrees that the image will be rotated by.
 *
 *  @return The image passed in rotated by the specified number of degrees.
 */
- (UIImage *)rotateImage:(UIImage*)image byDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation((degrees/180)*M_PI);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees/180)*M_PI);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

/**
 *  Takes an image and resizes it to the scale of the front facing camera. This is to speed up any processing on the image, lower disk consumption. For iPhone4/4s this is 480x640 or 640x480 and for iPhone5/5s it is (fill in).
 *
 *  @param image The image to be resized.
 *
 *  @return The resized image.
 */
- (UIImage *)resizedImage:(UIImage *)image {
    CGRect newRect;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight) {
        if (screenBound.size.height > 480) { // iphone 5 image
            //newRect = CGRectIntegral(CGRectMake(0, 0, , ));
        } else { // iphone 4 image
            newRect = CGRectIntegral(CGRectMake(0, 0, 480, 640));
        }
    } else if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown) {
        if (screenBound.size.height > 480) { // iphone 5 image
            //newRect = CGRectIntegral(CGRectMake(0, 0, , ));
        } else { // iphone 4 image
            newRect = CGRectIntegral(CGRectMake(0, 0, 640, 480));
        }
    }
    CGImageRef imageRef = image.CGImage;

    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));


    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);

    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);

    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);

    //return [self rotateImage:newImage byDegrees:180];
    return newImage;
}

/**
 *  Converts an image taken from the iPhone into the cv::cvMat format so that the OpenCV framework can perform image processing on the cv::cvMat.
 *
 *  @param image The image to be converted into cv::cvMat.
 *
 *  @return The cv::cvMat data type from the UIImage passed in.
 */
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationRight) { // requires 90 clockwise rotation
        //NSLog(@"Regular Portrait");
        image = [self rotateImage:image byDegrees:90];
    } else if (image.imageOrientation == UIImageOrientationLeft) { // 90 counter clock
        //NSLog(@"Upside Down Portrait");
        image = [self rotateImage:image byDegrees:-90];
    } else if (image.imageOrientation == UIImageOrientationDown) { // 180 rotation.
        //NSLog(@"Camera Bottom Landscape");
        image = [self rotateImage:image byDegrees:180];
    } // the final case is in the correct orientation
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    
    // this will prevent the 90 degree rotation after processing.
    CGFloat rows = image.size.height;
    CGFloat cols = image.size.width;

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

// convert image from cvMat to UIImage for after the image is processed.
/**
 *  Converts an OpenCV cv::cvMat formatted image into an Apple UIImage to be used for iOS or OSX applications.
 *
 *  @param cvMatImage The cv::cvMat data type to be converted into an Apple UIImage.
 *
 *  @return A UIImage.
 */
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

/**
 *  Uses OpenCV to detect human bodies in the images contained with in the array of data that is passed in. GSFData objects should be passed in and the GSFImage params will be filled. GSFImages lie within these GSFData objects and they are the images that will be used during the detection algorithm. Note: Detects Full Bodies such as a pedestrian.
 *
 *  @param capturedImages An Array of GSFData objects.
 */- (void)detectPeopleUsingImageArray:(NSMutableArray *)capturedImages
{
    cv::HOGDescriptor hog;
    hog.setSVMDetector(cv::HOGDescriptor::getDefaultPeopleDetector());
    
    for (GSFData *data in capturedImages) {
        cv::Mat matimg = [self cvMatFromUIImage:data.gsfImage.oimage];
        cv::vector<cv::Rect> found;
        cv::vector<cv::Rect> found_filtered;
        cv::Mat rgbMat(matimg.rows, matimg.cols, CV_8UC3); // 8 bits per component, 3 channels
        cvtColor(matimg, rgbMat, CV_RGBA2RGB, 3);
        hog.detectMultiScale(rgbMat, found, 0, cv::Size(8,8), cv::Size(32,32), 1.05, 2);
    
        size_t i, j;
        for (i = 0; i < found.size(); i++) {
            cv::Rect r = found[i];
            for (j = 0; j < found.size(); j++)
                if (j != i && (r & found[j]) == r)
                    break;
            if (j == found.size())
                found_filtered.push_back(r);
        }
        for (i = 0; i < found_filtered.size(); i++) {
            cv::Rect r = found_filtered[i];
            r.x += cvRound(r.width*0.1);
	        r.width = cvRound(r.width*0.8);
    	    r.y += cvRound(r.height*0.06);
	        r.height = cvRound(r.height*0.9);
            cv::rectangle(matimg, r.tl(), r.br(), cv::Scalar(0,255,0), 2);
	    }
        
        data.gsfImage.pimage = [self UIImageFromCvMat:matimg];
        data.gsfImage.personDetectionNumber = [NSNumber numberWithUnsignedLong:found.size()];
        NSLog(@"people: %d, %@", data.gsfImage.personDetectionNumber.intValue, data);
    }
}

/**
 *  Uses OpenCV to detect human faces in the images contained with in the array of data that is passed in. GSFData objects should be passed in and the GSFImage params will be filled. GSFImages lie within these GSFData objects and they are the images that will be used during the detection algorithm.
 *
 *  @param capturedImages An array of GSFData objects.
 */
- (void)detectFacesUsingImageArray:(NSMutableArray *)capturedImages
{
    for (GSFData *data in capturedImages) {
        cv::Mat matimg = [self cvMatFromUIImage:data.gsfImage.oimage];
        cv::Mat matgrey;
        cvtColor(matimg, matgrey, CV_BGR2GRAY);
        equalizeHist(matgrey, matgrey);
        cv::CascadeClassifier faceDetector;
        NSString *cascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
        int x = faceDetector.load([cascadePath UTF8String]);
        if (!x) NSLog(@"cascade load error");
        
        cv::vector<cv::Rect> faces;
        
        // find a better detectMultiScale???!?@?!#
        //faceDetector.detectMultiScale(matgrey, faces, 1, 1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30,30)); // look into documentation more for param info.
        
        faceDetector.detectMultiScale(matgrey, faces);
        
        for(size_t i = 0; i < faces.size(); i++ ) {
            cv::Point center(faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5);
            cv::ellipse(matimg, center, cv::Size(faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar(0, 255, 0), 4, 8, 0);
        }
        data.gsfImage.fimage = [self UIImageFromCvMat:matimg];
        data.gsfImage.faceDetectionNumber = [NSNumber numberWithUnsignedLong:faces.size()];
        NSLog(@"faces: %d, %@", data.gsfImage.faceDetectionNumber.intValue, data);
    }
}


@end

