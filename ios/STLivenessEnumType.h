//
//  STLivenessEnumType.h
//  STLivenessDetector
//
//  Created by sluin on 15/12/4.
//  Copyright © 2015年 SunLin. All rights reserved.
//

#ifndef STLivenessEnumType_h
#define STLivenessEnumType_h

/**
 *  活体检测失败类型
 */
typedef NS_ENUM(NSInteger, LivefaceErrorType) {
    /**
     *  License文件不合法(SenseID_Liveness_Interactive.lic)
     */
    STID_E_LICENSE_INVALID = 0,

    /**
     *  License文件未找到(SenseID_Liveness_Interactive.lic)
     */
    STID_E_LICENSE_FILE_NOT_FOUND,

    /**
     *  License绑定包名错误
     */
    STID_E_LICENSE_BUNDLE_ID_INVALID,

    /**
     *  License文件过期
     */
    STID_E_LICENSE_EXPIRE,

    /**
     *  License与SDK版本不匹配
     */
    STID_E_LICENSE_VERSION_MISMATCH,

    /**
     *  License不支持当前平台
     */
    STID_E_LICENSE_PLATFORM_NOT_SUPPORTED,

    /**
     *  Model文件不合法
     */
    STID_E_MODEL_INVALID,

    /**
     *  Model文件未找到
     */
    STID_E_MODEL_FILE_NOT_FOUND,

    /**
     *  模型文件过期
     */
    STID_E_MODEL_EXPIRE,
    /**
     * 没有人脸
     */
    STID_E_NOFACE_DETECTED,

    /**
     * 人脸遮挡
     */
    STID_FACE_OCCLUSION,
    /**
     *  检测超时
     */
    STID_E_TIMEOUT,

    /**
     *  参数设置不合法
     */
    STID_E_INVALID_ARGUMENTS,
    /**
     *  调用API状态错误
     */
    STID_E_CALL_API_IN_WRONG_STATE,


    /**
     *  API_KEY或API_SECRET错误
     */
    STID_E_API_KEY_INVALID,

    /**
     *  服务器访问错误
     */
    STID_E_SERVER_ACCESS,

    /**
     *  服务器访问超时
     */
    STID_E_SERVER_TIMEOUT,


    /**
     *  活体检测失败
     */
    STID_E_HACK,

};

/**
 *  设备错误的类型
 */
typedef NS_ENUM(NSUInteger, STIdDeveiceError) {
    /**
     *  相机权限获取失败
     */
    STID_E_CAMERA = 0,

    /**
     *  应用即将被挂起
     */
    STID_WILL_RESIGN_ACTIVE,
};

/**
 *  活体对准中人脸远近
 */
typedef NS_ENUM(NSInteger, LivenesssTrackerFaceDistanceStatus) {

    /**
     * 人脸距离手机过远
     */
    STID_FACE_TOO_FAR,
    /**
     * 人脸距离手机过近
     */
    STID_FACE_TOO_CLOSE,

    /**
     * 人脸距离正常
     */
    STID_DISTANCE_FACE_NORMAL,

    /**
     *人脸距离未知
     */
    STID_DISTANCE_UNKNOWN
};

/**
 *  活体对准中人脸的位置
 */
typedef NS_ENUM(NSInteger, LivenesssTrackerFaceBoundStatus) {
    /**
     * 没有人脸
     */
    STID_BOUND_NO_FACE,
    /**
     * 人脸在框内
     */
    STID_FACE_IN_BOUNDE,

    /**
     * 人脸出框
     */
    STID_BOUND_FACE_OUT_BOUND,

};

/**
 *  检测模块类型
 */
typedef NS_ENUM(NSInteger, LivefaceDetectionType) {

    /**
     *  眨眼检测
     */
    LIVE_BLINK,

    /**
     *  上下点头检测
     */
    LIVE_NOD,

    /**
     *  张嘴检测
     */
    LIVE_MOUTH,

    /**
     *  左右转头检测
     */
    LIVE_YAW
};

/**
 *  人脸方向
 */
typedef NS_ENUM(NSUInteger, LivefaceOrientaion) {
    /**
     *  人脸向上，即人脸朝向正常
     */
    LIVE_FACE_UP = 0,
    /**
     *  人脸向左，即人脸被逆时针旋转了90度
     */
    LIVE_FACE_LEFT = 1,
    /**
     *  人脸向下，即人脸被逆时针旋转了180度
     */
    LIVE_FACE_DOWN = 2,
    /**
     *  人脸向右，即人脸被逆时针旋转了270度
     */
    LIVE_FACE_RIGHT = 3
};

/**
 *  活体检测复杂度
 */
typedef NS_ENUM(NSUInteger, LivefaceComplexity) {

    /**
     *  简单, 人脸变更时不会回调 LIVENESS_FACE_CHANGED 错误, 活体阈值低
     */
    LIVE_COMPLEXITY_EASY,

    /**
     *  一般, 人脸变更时会回调 LIVENESS_FACE_CHANGED 错误, 活体阈值较低
     */
    LIVE_COMPLEXITY_NORMAL,

    /**
     *  较难, 人脸变更时会回调 LIVENESS_FACE_CHANGED 错误, 活体阈较高
     */
    LIVE_COMPLEXITY_HARD,

    /**
     *  困难, 人脸变更时会回调 LIVENESS_FACE_CHANGED 错误, 活体阈值高
     */
    LIVE_COMPLEXITY_HELL
};

#endif /* STLivenessEnumType_h */
