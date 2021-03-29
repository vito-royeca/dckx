//
//  ComicsPanelExtractor.cpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#include "ComicsPanelExtractor.hpp"

using namespace cv;
using namespace std;
using json = nlohmann::json;

json ComicsPanelExtractor::splitComics(const std::string& path, const float minimumPanelSizeRatio) {
    this->minimumPanelSizeRatio = minimumPanelSizeRatio;
    this->image = imread(path, IMREAD_COLOR);
    json j;
    

    if (image.empty()) {
        return j;
    }

    cv::Size s = this->image.size();
    j["size"] = {s.width, s.height};

    Mat gray;
    cv::cvtColor(this->image, gray, COLOR_BGR2GRAY);

    for (std::string bgColor : {"white", "black"}) {
        this->parse(gray, bgColor, j);
        
        if (j.find("panels") != j.end()) {
            return j;
        }
    }
    
    return j;
}

void ComicsPanelExtractor::parse(Mat gray, const std::string& bgColor, json& dictionary) {
    vector<vector<cv::Point>> contours = this->getContours(gray, bgColor);
    dictionary["background"] = bgColor;
    
    // Get (square) panels out of contours
    std::vector<int> sizeArray  = dictionary["size"].get<std::vector<int>>();
    int contourSize = std::accumulate(sizeArray.begin(), sizeArray.end(), 0) / 2 * 0.004;

    vector<Panel> panels;
    
    for(std::vector<vector<cv::Point>>::iterator it = std::begin(contours); it != std::end(contours); ++it) {
        double arcLength = cv::arcLength(*it, true);
        double epsilon = 0.001 * arcLength;
        vector<cv::Point> approx;
        cv::approxPolyDP(*it, approx, epsilon, true);
        
        Panel panel(NULL, &approx);
        
        // exclude very small panels
        int w = dictionary["size"].get<std::vector<int>>()[0];
        int h = dictionary["size"].get<std::vector<int>>()[1];
        if (panel.w < (w * this->minimumPanelSizeRatio) ||
            panel.h < (h * this->minimumPanelSizeRatio)) {
            continue;
        }
        
        panels.push_back(panel);
    }
    
    // See if panels can be cut into several (two non-consecutive points are close)
    this->splitPanels(panels, this->image, contourSize);
    
    // Merge panels that shouldn't have been split (speech bubble diving in a panel)
    this->mergePanels(panels);
    
    
    // splitting polygons may result in panels slightly overlapping, de-overlap them
    this->deoverlapPanels(panels);
    
    // get actual gutters before expanding panels
    json actualGutters = this->actualGutters(panels);
    dictionary["gutters"] = { actualGutters["x"], actualGutters["y"] };
    
//    std::sort (panels.begin(), panels.end());
    this->expandPanels(panels);
    
    if (panels.size() == 0) {
        cv::Rect rect(0, 0, dictionary["size"].get<std::vector<int>>()[0], dictionary["size"].get<std::vector<int>>()[1]);
        Panel panel(&rect, NULL);
        panels.push_back(panel);
    }
    
    // Number panels comics-wise (left to right for now)
    sort(panels.begin(), panels.end(), [](Panel p1, Panel p2) {
        return p1.x < p2.x;
    });
    
    // Simplify panels back to lists (x,y,w,h)
    json panelsDictionary;
    for (Panel p : panels) {
        panelsDictionary.push_back(p.toXywh());
    }
    
    dictionary["panels"] = panelsDictionary;
}

vector<vector<cv::Point>> ComicsPanelExtractor::getContours(Mat gray, const std::string& bgColor) {
    Mat thresh;
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    
    if (bgColor =="white") {
        // White background: values below 220 will be black, the rest white
        cv::threshold(gray, thresh, 220, 255, THRESH_BINARY_INV);
        cv::findContours(thresh, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    } else if (bgColor == "black") {
        // Black background: values above 25 will be black, the rest white
        cv::threshold(gray, thresh, 25, 255, THRESH_BINARY_INV);
        cv::findContours(thresh, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    }
    
    return contours;
}

void ComicsPanelExtractor::splitPanels(vector<Panel>& panels, Mat img, const int contourSize) {
    vector<Panel> newPanels;
    vector<Panel> oldPanels;
    
    for (Panel p : panels) {
        std::vector<Panel> splitPanels = p.split();
        
        if (splitPanels.size() > 0) {
            oldPanels.push_back(p);
            
            for (Panel np : newPanels) {
                newPanels.push_back(np);
            }
        }
    }
    
    for (Panel op : oldPanels) {
        for (int i=0; i<panels.size()-1; i++) {
            if (op == panels[i]) {
                panels.erase(panels.begin()+i);
            }
        }
    }
    for (Panel np : newPanels) {
        panels.push_back(np);
    }
}

// Merge every two panels where one contains the other
void ComicsPanelExtractor::mergePanels(std::vector<Panel>& panels) {
    vector<Panel> panelsToRemove;
    
    for (int i=0; i<panels.size()-1; i++) {
        for (int j=i+1; j<panels.size()-1; j++) {
            if (panels[i].contains(panels[j])) {
                panelsToRemove.push_back(panels[j]);
            }
            if (panels[j].contains(panels[i])) {
                panelsToRemove.push_back(panels[i]);
            }
            
        }
    }
    
    std::sort(panelsToRemove.begin(), panelsToRemove.end(), std::greater<Panel>());
    for (long i=panelsToRemove.size()-1; i==0; i--) {
        panels.erase(panels.begin()+i);
    }
}

void ComicsPanelExtractor::deoverlapPanels(std::vector<Panel>& panels) {
    for (int i=0; i<panels.size()-1; i++) {
        for (int j=0; j<panels.size()-1; j++) {
            if (panels[i] == panels[j]) {
                continue;
            }
            
            Panel *opanel = panels[i].overlapPanel(panels[j]);
            if (opanel == NULL) {
                continue;
            }
            
            if (opanel->w < opanel->h && panels[i].r == opanel->r) {
                panels[i].r = opanel->x;
                panels[j].x = opanel->r;
//                free(opanel);
                continue;
            }
            
            if (opanel->w > opanel->h && panels[i].b == opanel->b) {
                panels[i].b = opanel->y;
                panels[j].y = opanel->b;
//                free(opanel);
                continue;
            }
        }
    }
}
    
// Find out actual gutters between panels
json ComicsPanelExtractor::actualGutters(std::vector<Panel>& panels) {
    std::vector<int> guttersX;
    std::vector<int> guttersY;
    json j;
    
    for (Panel p : panels) {
        Panel *leftPanel = p.findLeftPanel(panels);
        if (leftPanel != NULL) {
            guttersX.push_back(p.x - leftPanel->r);
        }
        
        Panel *topPanel = p.findTopPanel(panels);
        if (topPanel != NULL) {
            guttersY.push_back(p.y - topPanel->b);
        }
    }
    
    if (guttersX.size() == 0) {
        guttersX.push_back(1);
    }
    if (guttersY.size() == 0) {
        guttersY.push_back(1);
    }
    
    j["x"] = *min_element(guttersX.begin(), guttersX.end());
    j["y"] = *min_element(guttersY.begin(), guttersY.end());
    j["r"] = -*min_element(guttersX.begin(), guttersX.end());
    j["b"] = -*min_element(guttersY.begin(), guttersY.end());
    return j;
}

// Expand panels to their neighbour's edge, or page frame
void ComicsPanelExtractor::expandPanels(std::vector<Panel>& panels) {
    json gutters = this->actualGutters(panels);
    
    for (Panel p : panels) {
        for (std::string d : {"x", "y", "r", "b"}) {
            json pcoords = {{"x", p.x}, {"y", p.y}, {"r", p.r}, {"b", p.b}};
            int newCoord = -1;
            int pAttribute = -1;
            Panel *neighbor = p.findNeighbourPanel(d, panels);
            
            if (neighbor != NULL) {
//                cout << "d=" << d << ", neihgbor=" << "[left:" << neighbor->x << ", right: " << neighbor->r << ", top: " << neighbor->y << ", bottom: " << neighbor->b << " (" << neighbor->w << "x" << neighbor->y << ")]" << endl;
                
                // expand to that neighbour's edge (minus gutter)
                if (d == "x") {
                    newCoord = neighbor->r;
                    pAttribute = p.x;
                } else if (d == "y") {
                    newCoord = neighbor->b;
                    pAttribute = p.y;
                } else if (d == "r") {
                    newCoord = neighbor->x;
                    pAttribute = p.r;
                } else if (d == "b") {
                    newCoord = neighbor->y;
                    pAttribute = p.b;
                }
                newCoord += gutters[d].get<int>();
            } else {
                // expand to the furthest known edge (frame around all panels)
                std::vector<Panel> sortedPanels;
                for (int i=0; i<panels.size(); i++) {
                    sortedPanels.push_back(panels[i]);
                }
                Panel *minPanel;
                
                
                if (d == "x" || d == "y") {
                    sort(sortedPanels.begin(), sortedPanels.end(), [](Panel p1, Panel p2) {
                        return p1.b > p2.b;
                    });
                } else {
                    sort(sortedPanels.begin(), sortedPanels.end(), [](Panel p1, Panel p2) {
                        return p1.b < p2.b;
                    });
                }
                minPanel = &sortedPanels.front();
                
                if (d == "x") {
                    newCoord = minPanel->x;
                    pAttribute = p.x;
                } else if (d == "y") {
                    newCoord = minPanel->y;
                    pAttribute = p.y;
                } else if (d == "r") {
                    newCoord = minPanel->r;
                    pAttribute = p.r;
                } else if (d == "b") {
                    newCoord = minPanel->b;
                    pAttribute = p.b;
                }
            }
            
            if (newCoord != -1) {
                if (((d == "r" || d == "b") && newCoord > pAttribute) ||
                    ((d == "x" || d == "y") && newCoord < pAttribute)) {
                    if (d == "x") {
                        p.x = newCoord;
                    } else if (d == "y") {
                        p.y = newCoord;
                    } else if (d == "r") {
                        p.r = newCoord;
                    } else if (d == "b") {
                        p.b = newCoord;
                    }
                }
            }
        }
    }

}
