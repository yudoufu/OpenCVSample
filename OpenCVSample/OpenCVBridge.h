//
//  OpenCVBridge.h
//  OpenCVSample
//
//  Created by yudoufu on 2016/12/13.
//  Copyright © 2016年 Personal. All rights reserved.
//

#ifndef OpenCVBridge_h
#define OpenCVBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVBridge : NSObject

+ (UIImage *)recognizeRect:(UIImage *)original;
+ (UIImage *)recognizeEdge:(UIImage *)original;

@end

#endif /* OpenCVBridge_h */
