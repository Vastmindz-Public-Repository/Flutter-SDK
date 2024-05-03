//
//  RPPGLandmark.h
//  rppglib
//
//  Created by Slava Zubrin on 22.12.2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RPPGLandmark : NSObject

@property (nonatomic, assign, readonly) double x;
@property (nonatomic, assign, readonly) double y;

- (instancetype)initX:(double)x Y:(double)y;

@end

NS_ASSUME_NONNULL_END
