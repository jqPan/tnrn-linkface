//
//  RNKitLinkFace.m
//  RNKitLinkFace
//
//  Created by SimMan on 2017/8/29.
//  Copyright © 2017年 RNKit.io. All rights reserved.
//

#import "RNKitLinkFace.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#else
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"
#import "RCTRootView.h"
#endif

#import "RNKitLinkFaceUtils.h"
#import "STLivenessController.h"
#import "STLivenessDetector.h"
#import "STImage.h"
#import "STAlertView.h"

NSString *const MultiLivenessDidStart = @"MultiLivenessDidStart";
NSString *const MultiLivenessDidFail = @"MultiLivenessDidFail";

@interface RNKitLinkFaceParam: NSObject
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *apiSecret;
@property (nonatomic, copy) NSString *outType;
@property (nonatomic, assign) LivefaceComplexity complexity;
@property (nonatomic, strong) NSArray *sequence;

+ (instancetype)linkFaceParamWith:(NSDictionary *)param;
- (NSError *)isValidParam;
@end

@interface RNKitLinkFace() <STLivenessDetectorDelegate, STLivenessControllerDelegate, STAlertViewDelegate>

@property (nonatomic , retain) STLivenessController *multipleLiveVC;

@end

@implementation RNKitLinkFace {
    BOOL _hasListener;
    RCTPromiseResolveBlock _resolve;
    RCTPromiseRejectBlock _reject;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
    return @[MultiLivenessDidStart, MultiLivenessDidFail];
}

RCT_EXPORT_METHOD(start:(NSDictionary *)args
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    _resolve = resolve;
    _reject = reject;
    
    [self clean];
    
    UIViewController *presentingController = RCTPresentedViewController();
    
    if (presentingController == nil) {
        RCTLogError(@"Tried to display action sheet picker view but there is no application window.");
        return;
    }
    
    if (!args) {
        reject(@"ArgsNull", @"参数不能为空", nil);
    }
    
    RNKitLinkFaceParam *param = [RNKitLinkFaceParam linkFaceParamWith:args];
    NSError *error = [param isValidParam];
    
    if (error) {
        reject(@"BadJson", error.domain, nil);
    }
    else {
        STLivenessController *livenessVC = [[STLivenessController alloc] initWithApiKey:param.apiKey
                                                                              apiSecret:param.apiSecret
                                                                            setDelegate:self
                                                                      detectionSequence:param.sequence];
        //设置每个模块的超时时间
        [livenessVC.detector setTimeOutDuration: 10];
        
        // 设置活体检测复杂度
        [livenessVC.detector setComplexity:param.complexity];
        
        // 设置活体检测的阈值
        [livenessVC.detector setHacknessThresholdScore:0.99];
        
        // 设置是否进行眉毛遮挡的检测，如不设置默认为不检测
        livenessVC.detector.isBrowOcclusion = NO;
        
        self.multipleLiveVC = livenessVC;
        [presentingController presentViewController:self.multipleLiveVC animated:YES completion:nil];
    }
}

RCT_EXPORT_METHOD(version:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    resolve([STLivenessDetector getVersion]);
}

RCT_EXPORT_METHOD(clean) {
    [RNKitLinkFaceUtils cleanLinkFacePath];
}

#pragma - mark private

- (void) faild:(NSString *)code message:(NSString *)message error:(NSError *)error
{
    if (_reject) {
        _reject(code, message, error);
        _reject = nil;
    }
    if (_hasListener) {
        [self sendEventWithName:MultiLivenessDidFail body:nil];
    }
}

- (void) dismiss {
    UIViewController *presentingController = RCTPresentedViewController();
    [presentingController dismissViewControllerAnimated:YES completion:nil];
}

- (void)startObserving
{
    _hasListener = YES;
}
- (void)stopObserving
{
    _hasListener = NO;
}

- (void)STAlertView:(STAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self.multipleLiveVC.detector cancelDetection];
            [self dismiss];
        }
            break;
        case 1:
        {
            [self.multipleLiveVC.detector startDetection];
        }
            break;
            
        default:
        {
            [self.multipleLiveVC.detector cancelDetection];
            [self dismiss];
        }
            break;
    }
}

#pragma - mark STLivenessDetectorDelegate

- (void)livenessOnlineBegin {
    if (_hasListener) {
        [self sendEventWithName:@"MultiLivenessDidStart" body:nil];
    }
}

- (void)livenessDidSuccessfulGetProtobufId:(NSString *)protobufId
                              protobufData:(NSData *)protobufData
                                 requestId:(NSString *)requestId
                                    images:(NSArray *)imageArr {
    NSMutableDictionary *resDic = [NSMutableDictionary new];
    
    if (protobufData) {
        NSString *encryTarDataPath = [RNKitLinkFaceUtils saveFaceData:protobufData];
        [resDic setObject:encryTarDataPath ? : [NSNull null] forKey:@"encryTarData"];
    }
    
    if (imageArr) {
        NSMutableArray *imgArr = [NSMutableArray arrayWithCapacity:imageArr.count];
        for (STImage *stImage in imageArr) {
            NSString *imgPath = [RNKitLinkFaceUtils saveFaceImage:stImage.image];
            [imgArr addObject:imgPath ? : [NSNull null]];
        }
        [resDic setObject:imgArr forKey:@"arrLFImage"];
    }
    
    if (_resolve) {
        _resolve(resDic);
        _resolve = nil;
    }
    [self dismiss];
}

- (void)livenessDidFailWithErrorType:(LivefaceErrorType)errorType
                        protobufData:(NSData *)protobufData
                           requestId:(NSString *)requestId
                              images:(NSArray *)imageArr {
    
    
    if (_reject) {
        switch (errorType) {
            case STID_E_LICENSE_INVALID: {
                [self faild:@"InitFaild" message:@"未通过授权验证" error:nil];
                break;
            }
            case STID_E_LICENSE_FILE_NOT_FOUND: {
                [self faild:@"InitFaild" message:@"授权文件不存在" error:nil];
                break;
            }
            case STID_E_LICENSE_BUNDLE_ID_INVALID: {
                [self faild:@"InitFaild" message:@"绑定包名错误" error:nil];
                break;
            }
            case STID_E_LICENSE_EXPIRE: {
                [self faild:@"InitFaild" message:@"授权文件过期" error:nil];
                break;
            }
            case STID_E_LICENSE_VERSION_MISMATCH: {
                [self faild:@"InitFaild" message:@"License与SDK版本不匹" error:nil];
                break;
            }
            case STID_E_LICENSE_PLATFORM_NOT_SUPPORTED: {
                [self faild:@"InitFaild" message:@"License不支持当前平台" error:nil];
                break;
            }
            case STID_E_MODEL_INVALID: {
                [self faild:@"InitFaild" message:@"模型文件错误" error:nil];
                break;
            }
            case STID_E_MODEL_FILE_NOT_FOUND: {
                [self faild:@"InitFaild" message:@"模型文件不存在" error:nil];
                break;
            }
            case STID_E_MODEL_EXPIRE: {
                [self faild:@"InitFaild" message:@"模型文件过期" error:nil];
                break;
            }
            case STID_E_NOFACE_DETECTED: {
                [self faild:@"InitFaild" message:@"动作幅度过⼤,请保持人脸在屏幕中央,重试⼀次" error:nil];
                break;
            }
            case STID_FACE_OCCLUSION: {
                [self faild:@"InitFaild" message:@"请调整人脸姿态，去除面部遮挡，正对屏幕重试一次" error:nil];
                break;
            }
            case STID_E_TIMEOUT: {
                [self faild:@"InitFaild" message:@"检测超时,请重试一次" error:nil];
                break;
            }
            case STID_E_INVALID_ARGUMENTS: {
                [self faild:@"InitFaild" message:@"参数设置不合法" error:nil];
                break;
            }
            case STID_E_CALL_API_IN_WRONG_STATE: {
                [self faild:@"InitFaild" message:@"错误的方法状态调用" error:nil];
                break;
            }
            case STID_E_API_KEY_INVALID: {
                [self faild:@"InitFaild" message:@"API_KEY或API_SECRET错误" error:nil];
                break;
            }
            case STID_E_SERVER_ACCESS: {
                [self faild:@"InitFaild" message:@"服务器访问错误" error:nil];
                break;
            }
            case STID_E_SERVER_TIMEOUT: {
                [self faild:@"InitFaild" message:@"网络连接超时，请查看网络设置，重试一次" error:nil];
                break;
            }
            case STID_E_HACK: {
                [self faild:@"InitFaild" message:@"未通过活体检测" error:nil];
                break;
            }
        }
    }
    [self dismiss];
}

- (void)livenessDidCancel {
    [self faild:@"Cancel" message:@"用户取消识别" error:nil];
    [self dismiss];
}

#pragma - mark STLivenessDetectorDelegate

- (void)livenessControllerDeveiceError:(STIdDeveiceError)deveiceError {
    switch (deveiceError) {
        case STID_E_CAMERA:
            [self faild:@"Cancel" message:@"相机权限获取失败:请在设置-隐私-相机中开启后重试" error:nil];
            break;
            
        case STID_WILL_RESIGN_ACTIVE:
            [self faild:@"Cancel" message:@"活体检测已经取消" error:nil];
            break;
    }
    [self dismiss];
}

@end

#pragma mark - RNKitLinkFaceParam

@implementation RNKitLinkFaceParam

+ (instancetype)linkFaceParamWith:(NSDictionary *)args {
    RNKitLinkFaceParam *param = [[RNKitLinkFaceParam alloc] init];
    param.complexity = 1;
    NSArray *keys = [args allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:@"apiKey"]) {
            param.apiKey = args[key];
        }
        else if ([key isEqualToString:@"apiSecret"]) {
            param.apiSecret = args[key];
        }
        else if ([key isEqualToString:@"outType"]) {
            param.outType = args[key];
        }
        else if ([key isEqualToString:@"Complexity"]) {
            param.complexity = [args[key] integerValue];
        }
        else if ([key isEqualToString:@"sequence"]) {
            NSArray *sequence = args[key];
            NSMutableArray *arrLivenessSequence = [NSMutableArray arrayWithCapacity:sequence.count];
            for (NSString *strAction in sequence) {
                if ([strAction isEqualToString:@"BLINK"]) {
                    [arrLivenessSequence addObject:@(LIVE_BLINK)];
                } else if ([strAction isEqualToString:@"MOUTH"]) {
                    [arrLivenessSequence addObject:@(LIVE_MOUTH)];
                } else if ([strAction isEqualToString:@"NOD"]) {
                    [arrLivenessSequence addObject:@(LIVE_NOD)];
                } else if ([strAction isEqualToString:@"YAW"]) {
                    [arrLivenessSequence addObject:@(LIVE_YAW)];
                }
            }
            param.sequence = [arrLivenessSequence copy];
        }
    }
    return param;
}

- (NSError *)isValidParam {
    if (self.apiKey.length == 0) {
        return [NSError errorWithDomain:@"linkFace ApiKey不存在！" code:999 userInfo:nil];
    }
    if (self.apiSecret.length == 0) {
        return [NSError errorWithDomain:@"linkFace Secret不存在！" code:999 userInfo:nil];
    }
    if (self.outType.length == 0) {
        return [NSError errorWithDomain:@"linkFace OutType不存在！" code:999 userInfo:nil];
    }
    if (self.sequence.count == 0) {
        return [NSError errorWithDomain:@"linkFace sequence不存在！" code:999 userInfo:nil];
    }
    return nil;
}
@end

