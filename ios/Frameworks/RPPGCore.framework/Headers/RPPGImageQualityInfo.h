//
//  RPPGImageQualityInfo.h
//  RPPGCore
//
//  Created by Slava Zubrin on 26.03.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPPGImageQualityInfo : NSObject

@property (nonatomic, assign, getter=isBrightColor) BOOL brightColor;
@property (nonatomic, assign, getter=isIlluminationChanges) BOOL illuminationChanges;
@property (nonatomic, assign, getter=isNoisy) BOOL noisy;
@property (nonatomic, assign, getter=isSharp) BOOL sharp;

@end

NS_ASSUME_NONNULL_END
