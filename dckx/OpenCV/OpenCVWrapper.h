//
//  OpenCVWrapper.h
//  dckx
//
//  Created by Vito Royeca on 4/17/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)getOpenCVVersion;
+ (void) split:(NSString*) fileName :(float) ratio :(void(^)(NSDictionary*))callback;

@end

NS_ASSUME_NONNULL_END
