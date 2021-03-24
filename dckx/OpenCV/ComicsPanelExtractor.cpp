//
//  ComicsPanelExtractor.cpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#include "ComicsPanelExtractor.hpp"
#include <opencv2/opencv.hpp>
#include <nlohmann_json/json.hpp>

using namespace cv;
using namespace std;
using json = nlohmann::json;

json ComicsPanelExtractor::splitComics(const std::string& path, const int minimumPanelSizeRatio) {
    json j;
    Mat img = imread(path, IMREAD_COLOR);

    if (img.empty()) {
        return j;
    }
    j["filename"] = path;

    cv::Size s = img.size();
    j["size"] = {s.width, s.height};

    Mat gray;
    cv::cvtColor(img, gray, COLOR_BGR2GRAY);

//    for (bgColor in ["white", "black"]) {
//        [self parse:img withGray: gray withBackgrundColor:bgColor withFilename: image_path withDictionary: dictionary];
//        
//        if ([dictionary objectForKey: @"panels"] != nil) {
//            return dictionary;
//        }
//    }
    
    return j;
}

void foo() {
    
}
/*
- (NSDictionary*) parse: (Mat) image withGray: (Mat) gray withBackgrundColor: (NSString*) bgColor withFilename: (std::string) filename withDictionary: (NSDictionary*) dictionary {
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary: dictionary];
    
    vector<vector<cv::Point>> contours = [self getContours:gray withBackgrundColor: bgColor];
    newDictionary[@"background"] = bgColor;

    // Get (square) panels out of contours
    NSNumber *sum = [dictionary[@"size"] valueForKeyPath:@"@sum.self"];
    int contourSize = int(sum.intValue / 2 * 0.004);
    
    NSMutableArray *panels = [[NSMutableArray alloc] init];
    for(std::vector<vector<cv::Point>>::iterator it = std::begin(contours); it != std::end(contours); ++it) {
        double arcLength = cv::arcLength(*it, true);
        double epsilon = 0.001 * arcLength;
        vector<cv::Point> approx;
        cv::approxPolyDP(*it, approx, epsilon, true);
        
        NSMutableArray *polygons = [[NSMutableArray alloc] init];
        for (cv::Point point : approx) {
            [polygons addObject: @(CGPointMake(point.x, point.y))];
        }
//        Panel *panel = [[Panel alloc] initWithPolygons: polygons];
        
        // exclude very small panels
    }
    
//    cv::arcLength(<#InputArray curve#>, <#bool closed#>)
//    panels = []
//    for contour in contours:
//        arclength = cv.arcLength(contour,True)
//        epsilon = 0.001 * arclength
//        approx = cv.approxPolyDP(contour,epsilon,True)
//
//        panel = Panel(polygon=approx)
//
//        # exclude very small panels
//        if panel.w < infos['size'][0] * self.options['min_panel_size_ratio'] or panel.h < infos['size'][1] * self.options['min_panel_size_ratio']:
//            continue
//
//        if self.options['debug_dir']:
//            cv.drawContours(self.img, [approx], 0, (0,0,255), contourSize)
//
//        panels.append(Panel(polygon=approx))
    
    return newDictionary;
    
}

- (vector<vector<cv::Point>>) getContours: (Mat) gray withBackgrundColor: (NSString*) bgColor {
    Mat thresh;//, contours, hierarchy;
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    
    if ([bgColor isEqualToString: @"white"]) {
        // White background: values below 220 will be black, the rest white
        cv::threshold(gray, thresh, 220, 255, THRESH_BINARY_INV);
        cv::findContours(thresh, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    } else if ([bgColor isEqualToString: @"black"]) {
        // Black background: values above 25 will be black, the rest white
        cv::threshold(gray, thresh, 25, 255, THRESH_BINARY_INV);
        cv::findContours(thresh, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    }
    
    return contours;
}
*/
