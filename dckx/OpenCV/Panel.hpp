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
using namespace cv;

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
    std::vector<int> toXywh();
    bool contains(Panel other);
    Panel* overlapPanel(Panel other);
    int area() { return this->w * this->h; }
    Panel* findTopPanel(std::vector<Panel>& panels);
    Panel* findLeftPanel(std::vector<Panel>& panels);
    Panel* findBottomPanel(std::vector<Panel>& panels);
    Panel* findRightPanel(std::vector<Panel>& panels);
    Panel* findNeighbourPanel(std::string d, std::vector<Panel>& panels);
    inline bool sameRow(Panel other) { return other.y <= this->y <= other.b || this->y <= other.y <= this->b; }
    inline bool sameCol(Panel other) { return other.x <= this->x <= other.r || this->x <= other.x <= this->r; }
private:
    
};

bool operator==(const Panel& lhs, const Panel& rhs);
bool operator< (const Panel& lhs, const Panel& rhs);
inline bool operator!=(const Panel& lhs, const Panel& rhs){ return !(lhs == rhs); }
inline bool operator> (const Panel& lhs, const Panel& rhs){ return !(lhs < rhs); }
inline bool operator<=(const Panel& lhs, const Panel& rhs){ return lhs < rhs; }
inline bool operator>=(const Panel& lhs, const Panel& rhs){ return lhs > rhs; }
std::ostream& operator<<(std::ostream &strm, const Panel &panel);

#endif /* Panel_hpp */
