//
//  Page.hpp
//  dckx
//
//  Created by Vito Royeca on 4/19/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef Page_hpp
#define Page_hpp


//class Page {
//public:
//    std::vector<Panel> panels;
//    std::vector<Segment> segments;
//    std::vector<int> imageSize;
//    float smallPanelRatio;
//    std::string numbering;
//};

#include <iostream>
#include <vector>
#include <string>
#include <cmath>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

class Panel;
class Segment;

#include "Panel.hpp"
#include "Segment.hpp"


class NotAnImageException : public exception {
public:
    NotAnImageException(const string& msg) : msg(msg) {}
    const char* what() const noexcept { return msg.c_str(); }
private:
    string msg;
};

class Page {
public:
    static constexpr double DEFAULT_MIN_PANEL_SIZE_RATIO = 0.1;
    
    vector<Panel> panels;
    vector<Segment> segments;
    string filename;
    string numbering;
    double smallPanelSizeRatio = DEFAULT_MIN_PANEL_SIZE_RATIO;
    bool panelExpansion;
    cv::Size imageSize;

    Page(const string& filename,
         const string& numbering = "ltr",
         double minPanelSizeRatio = DEFAULT_MIN_PANEL_SIZE_RATIO,
         bool panelExpansion = true);
    
    void split();

private:
    Mat image;
    Mat gray;
    Mat sobel;
    vector<vector<cv::Point>> contours;
    
    void getSobel();
    
    void getContours();
    
    void getSegments();
    
    void getInitialPanels();
    
    void groupSmallPanels();
    
    void splitPanels();
    
    void excludeSmallPanels();
    
    void deoverlapPanels();
    
    void mergePanels();
    
    cv::Point actualGutters(function<int(vector<int>)> func) const;
    
    double maxGutter() const;
    
    void expandPanels();
    
    void fixPanelsNumbering();
    
    void groupBigPanels();
};

                
#endif /* Page_hpp */
