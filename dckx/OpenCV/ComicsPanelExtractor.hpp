//
//  ComicsPanelExtractor.hpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#ifndef ComicsPanelExtractor_hpp
#define ComicsPanelExtractor_hpp


#include <numeric>

#include "Panel.hpp"

using namespace cv;
using namespace std;

class ComicsPanelExtractor {
    
public:
    float minimumPanelSizeRatio;
    Mat image;
//    json splitComics(const std::string& path, const float minimumPanelSizeRatio);
    
    ComicsPanelExtractor() {
        subpanelColours = {{0,255,0},{255,0,0},{200,200,0},{200,0,200},{0,200,200},{150,150,150}};
    }
private:
    vector<vector<int>> subpanelColours;
    
//    void parse(Mat gray, const std::string& bgColor, json& dictionary);
    vector<vector<cv::Point>> getContours(Mat gray, const std::string& bgColor);
    void splitPanels(vector<Panel>& panels, Mat img, const int contourSize);
    void mergePanels(std::vector<Panel>& panels);
    void deoverlapPanels(std::vector<Panel>& panels);
//    json actualGutters(std::vector<Panel>& panels);
    void expandPanels(std::vector<Panel>& panels);
};

#endif /* ComicsPanelExtractor_hpp */

