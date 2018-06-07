//
//  STFace.h
//  STLivenessDetector
//
//  Created by sluin on 16/2/29.
//  Copyright © 2016年 SunLin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, LivenesssOcclusionStatus) {
    /**
     * 遮挡未知
     */
    STID_UNKNOW = 0,

    /**
     * 未遮挡
     */
    STID_NORMAL,

    /**
     * 遮挡
     */
    STID_OCCLUSION,
};
@interface STFace : NSObject

/**
 *  对准阶段，眉毛的遮挡状态
 */
@property (assign, nonatomic) LivenesssOcclusionStatus browOcclusionStatus;
/**
 *  对准阶段，眼睛的遮挡状态
 */

@property (assign, nonatomic) LivenesssOcclusionStatus eyeOcclusionStatus;

/**
 *  对准阶段，鼻子的遮挡状态
 */
@property (assign, nonatomic) LivenesssOcclusionStatus noseOcclusionStatus;

/**
 *  对准阶段，嘴巴的遮挡状态
 */

@property (assign, nonatomic) LivenesssOcclusionStatus mouthOcclusionStatus;

@end
