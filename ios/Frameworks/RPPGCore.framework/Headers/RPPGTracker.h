//
//  RPPGTracker.h
//  rppglib
//
//  Created by Slava Zubrin on 22.12.2020.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RPPGLandmark;
@class RPPGImageQualityInfo;

@interface RPPGTracker : NSObject

- (NSArray<NSNumber *> *)extractBGRFrom:(UIImage * _Nonnull)image
                              timestamp:(NSTimeInterval)timestamp
                              landmarks:(NSArray<RPPGLandmark *> * _Nonnull)landmarks;
- (RPPGImageQualityInfo *)imageQuality;

@end

NS_ASSUME_NONNULL_END
