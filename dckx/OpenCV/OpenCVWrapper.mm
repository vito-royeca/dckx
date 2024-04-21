//
//  OpenCVWrapper.mm
//  dckx
//
//  Created by Vito Royeca on 3/22/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenCVWrapper.h"
#include "Page.hpp"
#include "Panel.hpp"
#include "Writer.hpp"

using namespace cv;
using namespace std;

@implementation OpenCVWrapper : NSObject

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"%s",  CV_VERSION];
}

+ (void) split:(NSString*) fileName :(float) ratio :(void(^)(NSDictionary*))callback {
    void (^callbackCopy)(NSDictionary*) = [callback copy];
    
//    NSLog(@"From Objective-C");
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    std::unique_ptr<Page> page;
    page.reset(new Page(std::string([fileName UTF8String])));
    page->split();
    
    dictionary[@"filename"] = [NSString stringWithCString: page->filename.c_str()
                                                 encoding: [NSString defaultCStringEncoding]];
    dictionary[@"numbering"] = [NSString stringWithCString: page->numbering.c_str()
                                                  encoding: [NSString defaultCStringEncoding]];
    
    id width = [NSNumber numberWithInt:page->imageSize.width];
    id height = [NSNumber numberWithInt:page->imageSize.height];
    id sizeArray = [NSMutableArray new];
    [sizeArray addObject:width];
    [sizeArray addObject:height];
    dictionary[@"size"] = sizeArray;
    
    id panelsArray = [NSMutableArray new];
    if (page->panels.size() > 1) {
        std::unique_ptr<Writer> writer;
        writer.reset(new Writer());
        writer->writerPanels(&*page);
        
        for (size_t i = 0; i < page->panels.size(); ++i) {
            NSMutableDictionary *panelsDictionary = [[NSMutableDictionary alloc] init];
            Panel panel = page->panels[i];
            
            id array = [NSMutableArray new];
            cv::Rect rect = panel.toXywh();
            [array addObject:[NSNumber numberWithInt:rect.x]];
            [array addObject:[NSNumber numberWithInt:rect.y]];
            [array addObject:[NSNumber numberWithInt:rect.width]];
            [array addObject:[NSNumber numberWithInt:rect.height]];
            panelsDictionary[@"rect"] = array;
            
            NSString *panelFilename = [NSString stringWithCString: page->panelFiles[i].c_str()
                                                         encoding: [NSString defaultCStringEncoding]];
            panelsDictionary[@"filename"] = panelFilename;
            
            [panelsArray addObject:panelsDictionary];
        }
    }
    dictionary[@"panels"] = panelsArray;

    callbackCopy(dictionary);
    callbackCopy = nil;
}

@end

