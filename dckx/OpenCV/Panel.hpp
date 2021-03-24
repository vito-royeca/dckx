//
//  Panel.hpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#ifndef Panel_hpp
#define Panel_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>

using namespace std;

class Panel {

public:
    std::string numbering;
    vector<cv::Point> polygons;
    int x;
    int y;
    int w;
    int wt;
    int h;
    int ht;
    int r;
    int b;
    
    Panel(cv::Rect* xywh, vector<cv::Point>* polygons);
    
    std::vector<Panel> split();
    bool contains(Panel other);
    Panel* overlapPanel(Panel other);
    int area() { return this->w * this->h; }
private:
    
};

bool operator==(const Panel& lhs, const Panel& rhs);
bool operator< (const Panel& lhs, const Panel& rhs);
inline bool operator!=(const Panel& lhs, const Panel& rhs){ return !(lhs == rhs); }
inline bool operator> (const Panel& lhs, const Panel& rhs){ return !(lhs < rhs); }
inline bool operator<=(const Panel& lhs, const Panel& rhs){ return lhs < rhs; }
inline bool operator>=(const Panel& lhs, const Panel& rhs){ return lhs > rhs; }

#endif /* Panel_hpp */
