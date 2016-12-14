//
//  OpenCVBridge.mm
//  OpenCVSample
//
//  Created by yudoufu on 2016/12/13.
//  Copyright © 2016年 Personal. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVBridge.h"

double const KernelSize = 9;
double const MinThreshold = 50;
double const MaxThreshold = 255;

@implementation OpenCVBridge: NSObject

// 書籍の矩形検索
+ (UIImage *)recognizeRect:(UIImage *)original
{
    // (1) 元画像のMat変数化
    cv::Mat mat;
    UIImageToMat(original, mat);

    // (2) 平滑化 & エッジ検出
    cv::Mat blurImage;
    cv::GaussianBlur(mat, blurImage, cv::Size(KernelSize, KernelSize), 0);

    cv::Mat edgeImage;
    cv::Canny(blurImage, edgeImage, MinThreshold, MaxThreshold, 3);

    // (3) 輪郭線の検出 & 描画
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(edgeImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);

    cv::Mat baseImage;
    cv::cvtColor(edgeImage, baseImage, CV_GRAY2RGB);

    for (auto contour = contours.begin(); contour != contours.end(); contour++) {
        cv::polylines(baseImage, *contour, true, cv::Scalar(0, 255, 0), 2);
    }

    // (4) 凸包の領域抽出 & 描画
    for (auto contour = contours.begin(); contour != contours.end(); contour++) {
        std::vector<cv::Point> approx;

        cv::convexHull(*contour, approx);

        double area = cv::contourArea(approx);
        if (approx.size() >= 4 && area > 50000) {
            cv::polylines(baseImage, approx, true, cv::Scalar(255, 0, 0), 2);
        }
    }
    
    return MatToUIImage(baseImage);
}

// エッジの検出
+ (UIImage *)recognizeEdge:(UIImage *)original
{
    cv::Mat mat;
    UIImageToMat(original, mat);

    cv::Mat blurImage;
    cv::GaussianBlur(mat, blurImage, cv::Size(KernelSize, KernelSize), 0);

    cv::Mat edgeImage;
    cv::Canny(blurImage, edgeImage, MinThreshold, MaxThreshold, 3);

    return MatToUIImage(edgeImage);
}

@end
