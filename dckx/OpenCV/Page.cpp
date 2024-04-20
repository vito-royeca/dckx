//
//  Page.cpp
//  dckx
//
//  Created by Vito Royeca on 4/19/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#include "Page.hpp"

#include "Panel.hpp"
#include "Segment.hpp"

Page::Page(const string& filename,
     const string& numbering,
     double minPanelSizeRatio,
     bool panelExpansion) {
    this->filename = filename;
    this->numbering = numbering;
    this->smallPanelSizeRatio = minPanelSizeRatio;
    this->panelExpansion = panelExpansion;
    
    this->image = imread(filename);
    if (!this->image.data) {
        throw NotAnImageException("File " + filename + " is not an image");
    }
    
    if (this->numbering != "ltr" && this->numbering != "rtl") {
        throw invalid_argument("Fatal error, unknown numbering: " + numbering);
    }
}

void Page::split() {
    getSobel();
    getContours();
    getSegments();
    getInitialPanels();
    groupSmallPanels();
    splitPanels();
    excludeSmallPanels();
    mergePanels();
    deoverlapPanels();
    excludeSmallPanels();
    
    if (panelExpansion) {
        sort(panels.begin(), panels.end());
        expandPanels();
    }
    
    if (panels.empty()) {
        vector<Point> polygon = vector<Point>{
            Point(0, 0),
            Point(imageSize.width, 0),
            Point(imageSize.width, imageSize.height),
            Point(0, imageSize.height) };
        panels.emplace_back(nullptr, nullptr, &polygon);
    }
    
    groupBigPanels();
    fixPanelsNumbering();
}

void Page::getSobel() {
    this->imageSize = this->image.size();
    cvtColor(this->image, this->gray, COLOR_BGR2GRAY);
    
    int dDepth = CV_16S;
    Mat gradX, gradY;
    Mat absGradX, absGradY;
    
    Sobel(gray, gradX, dDepth, 1, 0, 3, 1, 0, BORDER_DEFAULT);
    Sobel(gray, gradY, dDepth, 0, 1, 3, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(gradX, absGradX);
    convertScaleAbs(gradY, absGradY);
    addWeighted(absGradX, 0.5, absGradY, 0.5, 0, this->sobel);
}

void Page::getContours() {
    Mat thresh;
    cv::threshold(sobel, thresh, 100, 255, THRESH_BINARY);
    cv::findContours(thresh, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
}

void Page::getSegments() {
    segments.clear();
    
    Ptr<LineSegmentDetector> lsd = createLineSegmentDetector(0);
    vector<Vec4f> dLines;
    lsd->detect(gray, dLines);
    
    double minDist = min(imageSize.width, imageSize.height) * smallPanelSizeRatio;
    
    while (!segments.empty() || segments.size() > 500) {
        segments.clear();
        
        if (dLines.empty()) {
            break;
        }
        
        for (const Vec4f& dLine : dLines) {
            Point start(dLine[0], dLine[1]);
            Point end(dLine[2], dLine[3]);
            
            double dist = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2));
            if (dist >= minDist) {
                segments.emplace_back(start, end);
            }
        }
        
        minDist *= 1.1;
    }
    
    segments = Segment::unionAll(segments);
}

void Page::getInitialPanels() {
    panels.clear();
    
    for (const vector<cv::Point>& contour : contours) {
        double arcLength = cv::arcLength(contour, true);
        double epsilon = 0.001 * arcLength;
        vector<Point> approx;
        approxPolyDP(contour, approx, epsilon, true);
        
        Panel panel(nullptr, nullptr, &approx);
        if (!panel.isVerySmall()) {
            panels.push_back(panel);
        }
    }
}

void Page::groupSmallPanels() {
    vector<Panel> smallPanels;
    
    for (const Panel& panel : panels) {
        if (panel.isSmall()) {
            smallPanels.push_back(panel);
        }
    }
    
//    unordered_map<Panel, int> groups;
//    int groupID = 0;
//
//    for (size_t i = 0; i < smallPanels.size(); ++i) {
//        const Panel& p1 = smallPanels[i];
//        for (size_t j = i + 1; j < smallPanels.size(); ++j) {
//            const Panel& p2 = smallPanels[j];
//            if (p1 != p2 && p1.isClose(p2)) {
//                if (groups.count(p1) == 0 && groups.count(p2) == 0) {
//                    groups[p1] = ++groupID;
//                    groups[p2] = groupID;
//                } else if (groups.count(p1) > 0 && groups.count(p2) == 0) {
//                    groups[p2] = groups[p1];
//                } else if (groups.count(p1) == 0 && groups.count(p2) > 0) {
//                    groups[p1] = groups[p2];
//                } else if (groups[p1] != groups[p2]) {
//                    int oldGroup = groups[p2];
//                    int newGroup = groups[p1];
//                    for (auto& [panel, group] : groups) {
//                        if (group == oldGroup) {
//                            group = newGroup;
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    unordered_map<int, vector<Panel>> grouped;
//    for (const auto& [panel, group] : groups) {
//        grouped[group].push_back(panel);
//    }
//    
//    for (const auto& [group, panels] : grouped) {
//        vector<Point> bigHull;
//        for (const Panel& panel : panels) {
//            bigHull.insert(bigHull.end(), panel.polygon.begin(), panel.polygon.end());
//        }
//        convexHull(bigHull, bigHull);
//        Panel bigPanel(nullptr, nullptr, &bigHull);
//        this->panels.push_back(bigPanel);
//        for (const Panel& panel : panels) {
//            this->panels.erase(remove(this->panels.begin(), this->panels.end(), panel), this->panels.end());
//        }
//    }
}

void Page::splitPanels() {
    bool didSplit = true;

    while (didSplit) {
        didSplit = false;

        for (auto it = panels.begin(); it != panels.end(); ++it) {
            Panel split = it->split();
            if (!split.polygon.empty()) {
                didSplit = true;
                it = panels.erase(it);
                panels.insert(it, split);
                break;
            }
        }
    }
}

void Page::excludeSmallPanels() {
    panels.erase(remove_if(panels.begin(), panels.end(), [](const Panel& panel) { return panel.isSmall(); }), panels.end());
}

void Page::deoverlapPanels() {
    for (Panel& p1 : panels) {
        for (Panel& p2 : panels) {
            if (p1 != p2) {
                Panel overlap = p1.overlapPanel(p2);
                if (!overlap.polygon.empty()) {
                    if (overlap.w() < overlap.h() && p1.r == overlap.r) {
                        p1.r = overlap.x;
                        p2.x = overlap.r;
                        continue;
                    } else if (overlap.w() > overlap.h() && p1.y == overlap.y) {
                        p1.b = overlap.y;
                        p2.y = overlap.b;
                        continue;
                    }
                }
            }
        }
    }
}

void Page::mergePanels() {
    vector<Panel> panelsToRemove;

    for (size_t i = 0; i < panels.size(); ++i) {
        const Panel& p1 = panels[i];
        for (size_t j = i + 1; j < panels.size(); ++j) {
            const Panel& p2 = panels[j];
            if (p1.contains(p2)) {
                panelsToRemove.push_back(p2);
                panels[i] = p1.merge(p2);
            } else if (p2.contains(p1)) {
                panelsToRemove.push_back(p1);
                panels[j] = p2.merge(p1);
            }
        }
    }
    
    for (const Panel& panel : panelsToRemove) {
        panels.erase(remove(panels.begin(), panels.end(), panel), panels.end());
    }
}

Point Page::actualGutters(function<int(vector<int>)> func) const {
    vector<int> guttersX, guttersY;

    for (const Panel& panel : panels) {
        Panel leftPanel = panel.findLeftPanel();
        if (!leftPanel.polygon.empty()) {
            guttersX.push_back(panel.x - leftPanel.r);
        }
        
        Panel topPanel = panel.findTopPanel();
        if (!topPanel.polygon.empty()) {
            guttersY.push_back(panel.y - topPanel.b);
        }
    }
    
    if (guttersX.empty()) {
        guttersX.push_back(1);
    }
    if (guttersY.empty()) {
        guttersY.push_back(1);
    }
    
    double gutterX = func(guttersX);
    double gutterY = func(guttersY);
    return Point(-gutterX, -gutterY);
}

double Page::maxGutter() const {
    Point gutters = actualGutters([](const vector<int>& values) {
        return *max_element(values.begin(), values.end());
    });
    return max(abs(gutters.x), abs(gutters.y));
}

void Page::expandPanels() {
    Point gutters = actualGutters([](const vector<int>& values) {
        return *min_element(values.begin(), values.end());
    });
    
    for (Panel& panel : panels) {
        Rect rect = { panel.x, panel.y, panel.r, panel.b };
        rect.x -= gutters.x;
        rect.y -= gutters.y;
        rect.width += gutters.x;
        rect.height += gutters.y;
//        panel.polygon = vector<Point>(rect);
    }
    
//        gutters = self.actual_gutters()
//        for p in self.panels:
//            for d in ['x', 'y', 'r', 'b']:  # expand in all four directions
//                newcoord = -1
//                neighbour = p.find_neighbour_panel(d)
//                if neighbour:
//                    # expand to that neighbour's edge (minus gutter)
//                    newcoord = getattr(neighbour, {'x': 'r', 'r': 'x', 'y': 'b', 'b': 'y'}[d]) + gutters[d]
//                else:
//                    # expand to the furthest known edge (frame around all panels)
//                    min_panel = min(self.panels, key = lambda p: getattr(p, d)) if d in [
//                        'x', 'y'
//                    ] else max(self.panels, key = lambda p: getattr(p, d))
//                    newcoord = getattr(min_panel, d)
//
//                if newcoord != -1:
//                    if d in ['r', 'b'] and newcoord > getattr(p, d) or d in ['x', 'y'] and newcoord < getattr(p, d):
//                        setattr(p, d, newcoord)
}

void Page::fixPanelsNumbering() {
    bool changes = true;

    while (changes) {
        changes = false;

        for (size_t i = 0; i < panels.size(); ++i) {
            const Panel& panel = panels[i];
            vector<Panel> neighboursBefore;
            Panel topPanel = panel.findTopPanel();

            if (!topPanel.polygon.empty()) {
                neighboursBefore.push_back(topPanel);
            }
            if (numbering == "rtl") {
                vector<Panel> rightPanels = panel.findAllRightPanels();
                neighboursBefore.insert(neighboursBefore.end(), rightPanels.begin(), rightPanels.end());
            } else {
                vector<Panel> leftPanels = panel.findAllLeftPanels();
                neighboursBefore.insert(neighboursBefore.end(), leftPanels.begin(), leftPanels.end());
            }
            
            for (const Panel& neighbour : neighboursBefore) {
                auto neighbourPos = find(panels.begin(), panels.end(), neighbour) - panels.begin();
                if (i < neighbourPos) {
                    changes = true;
                    swap(panels[i], panels[neighbourPos]);
                    break;
                }
            }
            if (changes) {
                break;
            }
        }
    }
}

void Page::groupBigPanels() {
    bool grouped = true;

    while (grouped) {
        grouped = false;
        
        for (size_t i = 0; i < panels.size(); ++i) {
            for (size_t j = i + 1; j < panels.size(); ++j) {
                Panel p3 = panels[i].groupWith(panels[j]);

                std::vector<Panel> otherPanels;
                for (size_t k = 0; k < panels.size(); ++k) {
                    if (k != i && k != j) {
                        otherPanels.push_back(panels[k]);
                    }
                }

                if (p3.bumpsInto(otherPanels)) {
                    continue;
                }

                std::vector<Segment> segments;
                for (const auto& s : this->segments) {
                    if (p3.containsSegment(s) && s.dist() > p3.diagonal().dist() / 5) {
                        if (std::find(segments.begin(), segments.end(), s) == segments.end()) {
                            segments.push_back(s);
                        }
                    }
                }

                if (!segments.empty()) {
                    continue;
                }

                panels.push_back(p3);
                panels.erase(panels.begin() + i);
                panels.erase(panels.begin() + (j - 1)); // Adjust index after removal
                grouped = true;
                break;
            }

            if (grouped) {
                break;
            }
        }
    }
}
