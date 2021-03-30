//
//  Panel.cpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#include <iostream>
#include "Panel.hpp"

Panel::Panel(cv::Rect* xywh, vector<cv::Point>* polygons) {
    if (xywh == NULL && polygons == NULL) {
        throw "Fatal error: no parameter to define Panel boundaries";
    }
    
    this->numbering = "ltr";  // left-to-right by default
    
    cv::Rect rect;
    if (xywh == NULL) {
        rect = cv::boundingRect(*polygons);
    } else {
        rect = *xywh;
    }
    
    this->x = 0;
    this->y = 0;
    this->r = 0;
    this->b = 0;
    this->w = this->r - this->x;
    this->wt = this->w / 10;  // wt = width threshold (under which two edge coordinates are considered equal)
    this->h = this->b - this->y;
    this->ht = this->h / 10; // ht = height threshold
        
    this->x = rect.x;
    this->y = rect.y;
    this->w = rect.width;
    this->h = rect.height;
    this->r = this->x + rect.width;
    this->b = this->y + rect.height;
    
    if (polygons != NULL) {
        this->polygons = *polygons;
    }
}

std::vector<Panel> Panel::split() {
    if (this->polygons.size() == 0) {
        throw "Fatal error, trying to split a Panel with no polygon (not the result of opencv.findContours)";
    }
    std::vector<Panel> splitPanels;
    
    std::vector<vector<int>> closeDots;
    for (int i=0; i<this->polygons.size()-1; i++) {
        bool allClose = true;
        
        for (int j=i+1; j<this->polygons.size(); j++) {
            cv::Point dot1 = this->polygons[i];
            cv::Point dot2 = this->polygons[j];
//            cout << "dot1: " << dot1 << ", dot2: " << dot2 << endl;
            
            // elements that join panels together (e.g. speech bubbles) will be ignored (cut out) if their width and height is < min(panelwidth * ratio, panelheight * ratio)
            float ratio = 0.25;
            float maxDistance = min(this->w * ratio, this->h * ratio);
            
            if (abs(dot1.x-dot2.x) < maxDistance && abs(dot1.y-dot2.y) < maxDistance) {
                if (!allClose) {
                    closeDots.push_back({i, j});
                }
            } else {
                allClose = false;
            }
        }
    }
    
    if (closeDots.size() == 0) {
        return splitPanels;
    }
    
    // take the close dots that are closest from one another
//    std::vector<vector<int>> cuts;
//    sort(closeDots.begin(), closeDots.end(), [](cv::Point pt1, cv::Point pt2) {
//        return abs(pt1.x - pt2.x) < abs(pt1.y-pt2.y);
//    });
    
//    cout << "[";
//    for(std::vector<vector<int>>::iterator row = std::begin(closeDots); row != std::end(closeDots); ++row) {
//        cout << "[";
//        for(std::vector<int>::iterator elem = std::begin(*row); elem != std::end(*row); ++elem) {
//            cout << *elem << ",";
//        }
//        cout << "], ";
//    }
//    cout << "]" << endl;
    
    for(std::vector<vector<int>>::iterator cut = std::begin(closeDots); cut != std::end(closeDots); ++cut) {
        int poly1len = 0;
        int poly2len = 0;
        int index = 0;
        
        for(std::vector<int>::iterator elem = std::begin(*cut); elem != std::end(*cut); ++elem) {
            if (index == 0) {
                poly1len += *elem;
                poly2len -= *elem;
            } else if (index == 1) {
                poly1len -= *elem;
                poly2len += *elem;
            }
            index++;
        }
//        poly1len += this->polygons.size();
        
        // A panel should have at least three edges
        if (min(poly1len, poly2len) <= 2) {
            continue;
        }
//        cout << "poly1=" << poly1len << ", poly2=" << poly2len << endl;
        
        // Construct two subpolygons by distributing the dots around our cut (our close dots)
        vector<cv::Point> poly1;
        poly1.resize(poly1len);
        
        vector<cv::Point> poly2;
        poly2.resize(poly2len);
        
        int x = 0, y = 0;
        for (int i=0; i<this->polygons.size()-1; i++) {
            index = 0;
            
            for(std::vector<int>::iterator elem = std::begin(*cut); elem != std::end(*cut); ++elem) {
                if (index == 0) {
                    if (i <= *elem) {
                        poly1[x] = this->polygons[i];
                        x += 1;
                    } else {
                        poly2[y] = this->polygons[i];
                        y += 1;
                    }
                } else if (index == 1) {
                    if (i > *elem) {
                        poly1[x] = this->polygons[i];
                        x += 1;
                    } else {
                        poly2[y] = this->polygons[i];
                        y += 1;
                    }
                }
                index++;
            }
        }
        
        Panel panel1(NULL, &poly1);
        Panel panel2(NULL, &poly2);
        
        // Check that subpanels' width and height are not too small
        bool whOk = true;
        for (Panel p : {panel1,panel2}) {
            if (p.h / this->h < 0.1) {
                whOk = false;
            }
            if (p.w / this->w < 0.1) {
                whOk = false;
            }

            if (!whOk) {
                continue;
            }
        }
        
        // Check that subpanels' area is not too small
        double area1 = cv::contourArea(poly1);
        double area2 = cv::contourArea(poly2);
        if (max(area1, area2) == 0) {
            continue;
        }
        
        double areaRatio = min(area1,area2) / max(area1,area2);
        if (areaRatio < 0.1) {
            continue;
        }
        
        vector<Panel> subpanels1 = panel1.split();
        vector<Panel> subpanels2 = panel2.split();
        
        // resurse (find subsubpanels in subpanels)
        if (subpanels1.size() == 0) {
            for(std::vector<Panel>::iterator it = std::begin(subpanels1); it != std::end(subpanels1); ++it) {
                splitPanels.push_back(*it);
            }
        } else {
            splitPanels.push_back(panel1);
        }
        
        if (subpanels2.size() == 0) {
            for(std::vector<Panel>::iterator it = std::begin(subpanels2); it != std::end(subpanels2); ++it) {
                splitPanels.push_back(*it);
            }
        } else {
            splitPanels.push_back(panel2);
        }
    }
    
    return splitPanels;
    
    /*
     for cut in cuts:
         subpanels1 = panel1.split()
         subpanels2 = panel2.split()
         
         # resurse (find subsubpanels in subpanels)
         split_panels = []
         split_panels += [panel1] if subpanels1 is None else subpanels1
         split_panels += [panel2] if subpanels2 is None else subpanels2
         
         return split_panels
     
     return None
     
     */
}

std::vector<int> Panel::toXywh() {
    return { this->x, this->y, this->w, this->h };
}

bool Panel::contains(Panel other) {
    Panel *panel = this->overlapPanel(other);
    if (panel == NULL) {
//        free(panel);
        return false;
    }
    
    // self contains other if their overlapping area is more than 75% of other's area
    bool overlaps = panel->area() / other.area() > 0.75;
//    free(panel);
    return overlaps;
}

Panel* Panel::overlapPanel(Panel other) {
    if (this->x > other.r || other.x > this->r) {  // panels are left and right from one another
        return NULL;
    }
    if (this->y > other.b || other.y > this->b) {  // panels are above and below one another
        return NULL;
    }
    
    // if we're here, panels overlap at least a bit
    cv::Rect rect;
    rect.x = max(this->x, other.x);
    rect.y = max(this->y, other.y);
    rect.width = max(this->r, other.r);
    rect.height = max(this->b, other.b);
    Panel panel(&rect, NULL);
    
    return &panel;
}

Panel* Panel::findTopPanel(std::vector<Panel>& panels) {
    std::vector<Panel> allTop;
    
    Panel *thisPanel = this;
    std::copy_if (panels.begin(), panels.end(), std::back_inserter(allTop), [&thisPanel](Panel p) {
        return p.b <= thisPanel->y && p.sameCol(*thisPanel);
    });
    
    sort(allTop.begin(), allTop.end(), [](Panel p1, Panel p2) {
        return p1.b < p2.b;
    });
    return allTop.size() > 0 ? &allTop.front() : NULL;
}

Panel* Panel::findLeftPanel(std::vector<Panel>& panels) {
    std::vector<Panel> allLeft;
    
    Panel *thisPanel = this;
    std::copy_if (panels.begin(), panels.end(), std::back_inserter(allLeft), [&thisPanel](Panel p) {
        return p.r <= thisPanel->x && p.sameRow(*thisPanel);
    });
    
    sort(allLeft.begin(), allLeft.end(), [](Panel p1, Panel p2) {
        return p1.r < p2.r;
    });
    return allLeft.size() > 0 ? &allLeft.front() : NULL;
}

Panel* Panel::findBottomPanel(std::vector<Panel>& panels) {
    std::vector<Panel> allBottom;
    
    Panel *thisPanel = this;
    std::copy_if (panels.begin(), panels.end(), std::back_inserter(allBottom), [&thisPanel](Panel p) {
        return p.y <= thisPanel->b && p.sameCol(*thisPanel);
    });
    
    sort(allBottom.begin(), allBottom.end(), [](Panel p1, Panel p2) {
        return p1.y > p2.y;
    });
    return allBottom.size() > 0 ? &allBottom.front() : NULL;
}

Panel* Panel::findRightPanel(std::vector<Panel>& panels) {
    std::vector<Panel> allRight;
    
    Panel *thisPanel = this;
    std::copy_if (panels.begin(), panels.end(), std::back_inserter(allRight), [&thisPanel](Panel p) {
        return p.x <= thisPanel->r && p.sameRow(*thisPanel);
    });
    
    sort(allRight.begin(), allRight.end(), [](Panel p1, Panel p2) {
        return p1.x > p2.x;
    });
    return allRight.size() > 0 ? &allRight.front() : NULL;
}

Panel* Panel::findNeighbourPanel(std::string d, std::vector<Panel>& panels) {
    if (d == "x") {
        return this->findLeftPanel(panels);
    } else if (d == "y") {
        return this->findTopPanel(panels);
    } else if (d == "r") {
        return this->findRightPanel(panels);
    } else if (d == "b") {
        return this->findBottomPanel(panels);
    } else {
        return NULL;
    }
}

// Overloads
bool operator==(const Panel& lhs, const Panel& rhs) {
    return
        abs(lhs.x-rhs.x) < lhs.wt &&
        abs(lhs.y-rhs.y) < lhs.ht &&
        abs(lhs.r-rhs.r) < lhs.wt &&
        abs(lhs.b-rhs.b) < lhs.ht;
}

bool operator< (const Panel& lhs, const Panel& rhs) {
    // panel is above other
    if (rhs.y >= lhs.b - lhs.ht && rhs.y >= lhs.y - lhs.ht) {
        return true;
    }
    
    // panel is below other
    if (lhs.y >= rhs.b - lhs.ht && rhs.y >= rhs.y - lhs.ht) {
        return false;
    }
    
    // panel is left from other
    if (rhs.x >= lhs.r - lhs.wt && rhs.x >= lhs.x - lhs.wt) {
        return lhs.numbering == "ltr";
    }
    
    // panel is right from other
    if (lhs.x >= rhs.r - lhs.wt && lhs.x >= rhs.x - lhs.wt) {
        return lhs.numbering != "ltr";
    }
    
    return true;  // should not happen, TODO: raise an exception?
}

std::ostream& operator<<(std::ostream &strm, const Panel &panel) {
    return strm << "[left:" << panel.x << ", right: " << panel.r << ", top: " << panel.y << ", bottom: " << panel.b << " (" << panel.w << "x" << panel.y << ")]";
}
