//
//  Page.hpp
//  dckx
//
//  Created by Vito Royeca on 4/19/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef Page_hpp
#define Page_hpp

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

    Mat image;
    vector<Panel> panels;
    vector<Segment> segments;
    string filename;
    vector<string> panelFiles;
    string numbering;
    cv::Size imageSize;
    double smallPanelSizeRatio = DEFAULT_MIN_PANEL_SIZE_RATIO;

    Page(const string& filename,
         const string& numbering = "ltr",
         double minPanelSizeRatio = DEFAULT_MIN_PANEL_SIZE_RATIO,
         bool panelExpansion = true);
    
    void split();

private:
    Mat gray;
    Mat sobel;
    vector<vector<cv::Point>> contours;
    bool panelExpansion;
    
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
