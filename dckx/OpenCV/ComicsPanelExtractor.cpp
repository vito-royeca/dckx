//
//  ComicsPanelExtractor.cpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#include "ComicsPanelExtractor.hpp"

#include <iostream>

using namespace cv;
using namespace std;

ComicsData ComicsPanelExtractor::splitComics(const std::string& path, const float minimumPanelSizeRatio) {
//    this->minimumPanelSizeRatio = minimumPanelSizeRatio;
//    this->image = imread(path);
    ComicsData data;
//    
//    if (image.empty()) {
//        return data;
//    }
//
//    cv::Size s = this->image.size();
//    this->imageSize = {s.width, s.height};
//    data.size = this->imageSize;
//
//    calculateSobel();
//    getContours();
//    getSegments();

//    self.get_initial_panels()
//    self.group_small_panels()
//    self.split_panels()
//    self.exclude_small_panels()
//    self.merge_panels()
//    self.deoverlap_panels()
//    self.exclude_small_panels()
//
//    if self.panel_expansion:
//        self.panels.sort()  # TODO: move this below before panels sort-fix, when panels expansion is smarter
//        self.expand_panels()
//
//    if len(self.panels) == 0:
//        self.panels.append(Panel(page = self, xywh = [0, 0, self.img_size[0], self.img_size[1]]))
//
//    self.group_big_panels()
//
//    self.fix_panels_numbering()
                
//    for (std::string bgColor : {"white", "black"}) {
//        this->parse(gray, bgColor, data);
//        
//        if (!data.panels.empty()) {
//            return data;
//        }
//    }
    
    return data;
}

void ComicsPanelExtractor::calculateSobel() {
//    int ddepth = CV_16S;
//    Mat grad_x, grad_y;
//    Mat abs_grad_x, abs_grad_y;
//
//    cvtColor(this->image, this->gray, COLOR_BGR2GRAY);
//    Sobel(this->gray, grad_x, ddepth, 1, 0);
//    Sobel(this->gray, grad_y, ddepth, 0, 1);
//    convertScaleAbs(grad_x, abs_grad_x);
//    convertScaleAbs(grad_y, abs_grad_y);
//    addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, this->sobel);
}

void ComicsPanelExtractor::getContours() {
//    Mat thresh;
//    vector<vector<cv::Point>> contours;
//    vector<Vec4i> hierarchy;
//    
//    if (bgColor =="white") {
//        // White background: values below 220 will be black, the rest white
//        cv::threshold(gray, thresh, 220, 255, THRESH_BINARY_INV);
//        cv::findContours(thresh, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
//    } else if (bgColor == "black") {
//        // Black background: values above 25 will be black, the rest white
//        cv::threshold(gray, thresh, 25, 255, THRESH_BINARY_INV);
//        cv::findContours(thresh, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
//    }
//    
//    return contours;
    
//    Mat thresh;
//    Mat hierarchy;
//    cv::threshold(this->sobel, thresh, 100, 255, THRESH_BINARY);
//    cv::findContours(thresh, this->contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
}

void ComicsPanelExtractor::getSegments() {
//    Ptr<LineSegmentDetector> lsd = cv::createLineSegmentDetector();
//    Mat dlines;
//    
//    lsd->detect(this->gray, dlines);
//    int minDist = min(this->imageSize[0], this->imageSize[1]) * this->minimumPanelSizeRatio;
    
//    self.segments = None
//
//    lsd = cv.createLineSegmentDetector(0)
//    dlines = lsd.detect(self.gray)
//
//    Debug.show_time("Detected segments")
//
//    min_dist = min(self.img_size) * self.small_panel_ratio
//
//    while self.segments is None or len(self.segments) > 500:
//        self.segments = []
//
//        if dlines is None or dlines[0] is None:
//            break
//
//        for dline in dlines[0]:
//            x0 = int(round(dline[0][0]))
//            y0 = int(round(dline[0][1]))
//            x1 = int(round(dline[0][2]))
//            y1 = int(round(dline[0][3]))
//
//            a = x0 - x1
//            b = y0 - y1
//            dist = math.sqrt(a**2 + b**2)
//            if dist >= min_dist:
//                self.segments.append(Segment([x0, y0], [x1, y1]))
//
//        min_dist *= 1.1
//
//    self.segments = Segment.union_all(self.segments)
//
//    Debug.draw_segments(self.segments, Debug.colours['green'])
//    Debug.add_image("Segment Detector")
//    Debug.show_time("Compiled segments")
}

//void ComicsPanelExtractor::parse(Mat gray, const std::string& bgColor, ComicsData& data) {
//    vector<vector<cv::Point>> contours = this->getContours(gray, bgColor);
//    data.background = bgColor;
//    
//    // Get (square) panels out of contours
//    std::vector<int> sizeArray = data.size;
//    int contourSize = std::accumulate(sizeArray.begin(), sizeArray.end(), 0) / 2 * 0.004;
//
//    vector<Panel> panels;
//    
//    for(std::vector<vector<cv::Point>>::iterator it = std::begin(contours); it != std::end(contours); ++it) {
//        double arcLength = cv::arcLength(*it, true);
//        double epsilon = 0.001 * arcLength;
//        vector<cv::Point> approx;
//        cv::approxPolyDP(*it, approx, epsilon, true);
//        
//        Panel panel(NULL, &approx);
//        
//        // exclude very small panels
//        int w = data.size[0];
//        int h = data.size[1];
//        if (panel.w < (w * this->minimumPanelSizeRatio) ||
//            panel.h < (h * this->minimumPanelSizeRatio)) {
//            continue;
//        }
//        
//        panels.push_back(panel);
//    }
//    
//    // See if panels can be cut into several (two non-consecutive points are close)
//    this->splitPanels(panels, this->image, contourSize);
//    
//    // Merge panels that shouldn't have been split (speech bubble diving in a panel)
//    this->mergePanels(panels);
//    
//    
//    // splitting polygons may result in panels slightly overlapping, de-overlap them
//    this->deoverlapPanels(panels);
//    
//    // get actual gutters before expanding panels
//    Panel actualGutters = this->actualGutters(panels);
//    data.gutters = { actualGutters.x, actualGutters.y };
//    
////    std::sort (panels.begin(), panels.end());
//    this->expandPanels(panels);
//    
//    if (panels.size() == 0) {
//        cv::Rect rect(0, 0, data.size[0], data.size[1]);
//        Panel panel(&rect, NULL);
//        panels.push_back(panel);
//    }
//    
//    // Number panels comics-wise (left to right for now)
//    sort(panels.begin(), panels.end(), [](Panel p1, Panel p2) {
//        return p1.x < p2.x;
//    });
//    
//    // Simplify panels back to lists (x,y,w,h)
//    vector<vector<int>> panelsArray;
//    for (Panel p : panels) {
//        panelsArray.push_back(p.toXywh());
//    }
//    
//    data.panels = panelsArray;
//}



//void ComicsPanelExtractor::splitPanels(vector<Panel>& panels, Mat img, const int contourSize) {
//    vector<Panel> newPanels;
//    vector<Panel> oldPanels;
//    
//    for (Panel p : panels) {
//        std::vector<Panel> splitPanels = p.split();
//        
//        if (splitPanels.size() > 0) {
//            oldPanels.push_back(p);
//            
//            for (Panel np : newPanels) {
//                newPanels.push_back(np);
//            }
//        }
//    }
//    
//    for (Panel op : oldPanels) {
//        for (int i=0; i<panels.size()-1; i++) {
//            if (op == panels[i]) {
//                panels.erase(panels.begin()+i);
//            }
//        }
//    }
//    for (Panel np : newPanels) {
//        panels.push_back(np);
//    }
//}

// Merge every two panels where one contains the other
//void ComicsPanelExtractor::mergePanels(std::vector<Panel>& panels) {
//    if (panels.size() == 0) {
//        return;
//    }
//    
//    vector<Panel> panelsToRemove;
//    
//    for (int i=0; i<panels.size()-1; i++) {
//        for (int j=i+1; j<panels.size()-1; j++) {
//            if (panels[i].contains(panels[j])) {
//                panelsToRemove.push_back(panels[j]);
//            }
//            if (panels[j].contains(panels[i])) {
//                panelsToRemove.push_back(panels[i]);
//            }
//            
//        }
//    }
//    
//    std::sort(panelsToRemove.begin(), panelsToRemove.end(), std::greater<Panel>());
//    for (long i=panelsToRemove.size()-1; i==0; i--) {
//        panels.erase(panels.begin()+i);
//    }
//}

//void ComicsPanelExtractor::deoverlapPanels(std::vector<Panel>& panels) {
//    if (panels.size() == 0) {
//        return;
//    }

//    for (int i=0; i<panels.size()-1; i++) {
//        for (int j=0; j<panels.size()-1; j++) {
//            if (panels[i] == panels[j]) {
//                continue;
//            }
//            
//            Panel *opanel = panels[i].overlapPanel(panels[j]);
//            if (opanel == NULL) {
//                continue;
//            }
//            
//            if (opanel->w < opanel->h && panels[i].r == opanel->r) {
//                panels[i].r = opanel->x;
//                panels[j].x = opanel->r;
////                free(opanel);
//                continue;
//            }
//            
//            if (opanel->w > opanel->h && panels[i].b == opanel->b) {
//                panels[i].b = opanel->y;
//                panels[j].y = opanel->b;
////                free(opanel);
//                continue;
//            }
//        }
//    }
//}
    
// Find out actual gutters between panels
//Panel ComicsPanelExtractor::actualGutters(std::vector<Panel>& panels) {
//    std::vector<int> guttersX;
//    std::vector<int> guttersY;
//    Rect xywh;
//    Panel gutters(&xywh, NULL);
//    
//    for (Panel p : panels) {
//        Panel *leftPanel = p.findLeftPanel(panels);
//        if (leftPanel != NULL) {
//            guttersX.push_back(p.x - leftPanel->r);
//        }
//        
//        Panel *topPanel = p.findTopPanel(panels);
//        if (topPanel != NULL) {
//            guttersY.push_back(p.y - topPanel->b);
//        }
//    }
//    
//    if (guttersX.size() == 0) {
//        guttersX.push_back(1);
//    }
//    if (guttersY.size() == 0) {
//        guttersY.push_back(1);
//    }
//    
//    gutters.x = *min_element(guttersX.begin(), guttersX.end());
//    gutters.y = *min_element(guttersY.begin(), guttersY.end());
//    gutters.r = -*min_element(guttersX.begin(), guttersX.end());
//    gutters.b = -*min_element(guttersY.begin(), guttersY.end());
//    return gutters;
//}

// Expand panels to their neighbour's edge, or page frame
//void ComicsPanelExtractor::expandPanels(std::vector<Panel>& panels) {
//    Panel gutters = this->actualGutters(panels);
//    
//    for (Panel p : panels) {
//        for (std::string d : {"x", "y", "r", "b"}) {
////            ComicsData pcoords;
////            pcoords.x = p.x;
////            pcoords.x = p.y;
////            pcoords.r = p.r;
////            pcoords.b = p.b;
//            
//            int newCoord = -1;
//            int pAttribute = -1;
//            Panel *neighbor = p.findNeighbourPanel(d, panels);
//            
//            if (neighbor != NULL) {
//                cout << "d=" << d << ", neihgbor=" << "[left:" << neighbor->x << ", right: " << neighbor->r << ", top: " << neighbor->y << ", bottom: " << neighbor->b << " (" << neighbor->w << "x" << neighbor->y << ")]" << endl;
//                
//                // expand to that neighbour's edge (minus gutter)
//                if (d == "x") {
//                    newCoord = neighbor->r;
//                    pAttribute = p.x;
//                    newCoord += gutters.x;
//                } else if (d == "y") {
//                    newCoord = neighbor->b;
//                    pAttribute = p.y;
//                    newCoord += gutters.y;
//                } else if (d == "r") {
//                    newCoord = neighbor->x;
//                    pAttribute = p.r;
//                    newCoord += gutters.r;
//                } else if (d == "b") {
//                    newCoord = neighbor->y;
//                    pAttribute = p.b;
//                    newCoord += gutters.b;
//                }
//            } else {
//                // expand to the furthest known edge (frame around all panels)
//                std::vector<Panel> sortedPanels;
//                for (int i=0; i<panels.size(); i++) {
//                    sortedPanels.push_back(panels[i]);
//                }
//                Panel *minPanel;
//                
//                
//                if (d == "x" || d == "y") {
//                    sort(sortedPanels.begin(), sortedPanels.end(), [](Panel p1, Panel p2) {
//                        return p1.b > p2.b;
//                    });
//                } else {
//                    sort(sortedPanels.begin(), sortedPanels.end(), [](Panel p1, Panel p2) {
//                        return p1.b < p2.b;
//                    });
//                }
//                minPanel = &sortedPanels.front();
//                
//                if (d == "x") {
//                    newCoord = minPanel->x;
//                    pAttribute = p.x;
//                } else if (d == "y") {
//                    newCoord = minPanel->y;
//                    pAttribute = p.y;
//                } else if (d == "r") {
//                    newCoord = minPanel->r;
//                    pAttribute = p.r;
//                } else if (d == "b") {
//                    newCoord = minPanel->b;
//                    pAttribute = p.b;
//                }
//            }
//            
//            if (newCoord != -1) {
//                if (((d == "r" || d == "b") && newCoord > pAttribute) ||
//                    ((d == "x" || d == "y") && newCoord < pAttribute)) {
//                    if (d == "x") {
//                        p.x = newCoord;
//                    } else if (d == "y") {
//                        p.y = newCoord;
//                    } else if (d == "r") {
//                        p.r = newCoord;
//                    } else if (d == "b") {
//                        p.b = newCoord;
//                    }
//                }
//            }
//        }
//    }
//}
