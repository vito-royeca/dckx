//
//  OpenCVWrapper.h
//  dckx
//
//  Created by Vito Royeca on 3/22/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

+ (NSDictionary*) splitComics:(NSString*) path minimumPanelSizeRatio:(float) ratio;

@end

#endif /* OpenCVWrapper_h */
