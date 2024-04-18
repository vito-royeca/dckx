//
//  OpenCVWrapper.mm
//  dckx
//
//  Created by Vito Royeca on 3/22/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenCVWrapper.h"
#include "ComicsPanelExtractor.hpp"
#include "Panel.hpp"

using namespace cv;
using namespace std;

@implementation OpenCVWrapper : NSObject

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (void) split:(NSString*) fileName :(float) ratio :(void(^)(NSDictionary*))callback {
    void (^callbackCopy)(NSDictionary*) = [callback copy];
    
    NSLog(@"From Objective-C");
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    ComicsPanelExtractor comics;
    ComicsData data = comics.splitComics(std::string([fileName UTF8String]), ratio);
    
    dictionary[@"background"] = [NSString stringWithUTF8String:data.background.c_str()];;
    
    id sizeArray = [NSMutableArray new];
    for (auto foo : data.size) {
        id number = [NSNumber numberWithInt:foo];
        [sizeArray addObject:number];
    }
    dictionary[@"size"] = sizeArray;
    
    id guttersArray = [NSMutableArray new];
    for (auto foo : data.gutters) {
        id number = [NSNumber numberWithInt:foo];
        [guttersArray addObject:number];
    }
    dictionary[@"gutters"] = guttersArray;
    
    id panelsArray = [NSMutableArray new];
    for (auto foo : data.panels) {
        id array = [NSMutableArray new];
        for (auto foo2 : foo) {
            id number = [NSNumber numberWithInt:foo2];
            [array addObject:number];
        }
        
        [panelsArray addObject:array];
    }
    dictionary[@"panels"] = panelsArray;
    
    callbackCopy(dictionary);
//    [callback release];
    callbackCopy = nil;
}

@end

