//
//  STImage.h
//  STLivenessDetector
//
//  Created by sluin on 16/3/24.
//  Copyright © 2016年 SunLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STLivenessEnumType.h"

@interface STImage : NSObject

/**
 *  图片
 */
@property (strong, nonatomic) UIImage *image;

/**
 *  图片在动作序列中的位置, 0为第一个
 */
@property (assign, nonatomic) NSInteger index;

/**
 *  图片所属的检测模块类型
 */
@property (assign, nonatomic) LivefaceDetectionType detectionType;

@end
