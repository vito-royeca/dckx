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

//+ (NSDictionary*) splitComics:(NSString*) path minimumPanelSizeRatio:(float) ratio {
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//    ComicsPanelExtractor comics;
//    json j = comics.splitComics(std::string([path UTF8String]), ratio);
//    
//    for (const auto& item : j.items()) {
//        NSString *key = [NSString stringWithCString: item.key().c_str()
//                                           encoding: [NSString defaultCStringEncoding]];
//        NSObject *value;
//
//        if ([key isEqualToString:@"size"] ||
//                   [key isEqualToString:@"gutters"]) {
//            vector<int> size = item.value().get<vector<int>>();
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//
//            for(vector<int>::iterator it = std::begin(size); it != std::end(size); ++it) {
//                [array addObject: [NSNumber numberWithInt: *it]];
//            }
//            value = array;
//        } else if ([key isEqualToString:@"background"]) {
//            value = [NSString stringWithCString: item.value().get<std::string>().c_str()
//                                       encoding: [NSString defaultCStringEncoding]];
//        } else if ([key isEqualToString:@"panels"]) {
//            vector<vector<int>> size = item.value().get<vector<vector<int>>>();
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//
//            for(vector<vector<int>>::iterator it = std::begin(size); it != std::end(size); ++it) {
//                NSMutableArray *array2 = [[NSMutableArray alloc] init];
//                for(vector<int>::iterator it2 = std::begin(*it); it2 != std::end(*it); ++it2) {
//                    [array2 addObject: [NSNumber numberWithInt: *it2]];
//                }
//                [array addObject:array2];
//            }
//            value = array;
//        }
//
//        dictionary[key] = value;
//    }
//    
//    return dictionary;
//}

//+ (ComicsData*) splitComics:(NSString*) path minimumPanelSizeRatio:(float) ratio {
//    Cat *cat = [Cat create];
//    ComicsData *comicsData = ComicsData ini
//    return NULL;
//}

@end

