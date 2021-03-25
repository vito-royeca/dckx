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
    
    std::vector<int> closeDots;
    for (int i=0; i<this->polygons.size()-1; i++) {
        bool allClose = true;
        
        for (int j=i+1; j<this->polygons.size(); j++) {
            cv::Point dot1 = this->polygons[i];
            
//            int dot2 = this->polygons[j][0];
        }
    }
    
    std::vector<Panel> panels;
    
    return panels;
    
    /*
     if self.polygon is None:
         raise Exception('Fatal error, trying to split a Panel with no polygon (not the result of opencv.findContours)')
     
     close_dots = []
     for i in range(len(self.polygon)-1):
         all_close = True
         for j in range(i+1,len(self.polygon)):
             dot1 = self.polygon[i][0]
             dot2 = self.polygon[j][0]
             
             # elements that join panels together (e.g. speech bubbles) will be ignored (cut out) if their width and height is < min(panelwidth * ratio, panelheight * ratio)
             ratio = 0.25
             max_dist = min(self.w * ratio, self.h * ratio)
             if abs(dot1[0]-dot2[0]) < max_dist and abs(dot1[1]-dot2[1]) < max_dist:
                 if not all_close:
                     close_dots.append([i,j])
             else:
                 all_close = False
     
     if len(close_dots) == 0:
         return None
     
     # take the close dots that are closest from one another
     cuts = sorted(close_dots, key=lambda d:
         abs(self.polygon[d[0]][0][0]-self.polygon[d[1]][0][0]) +  # dot1.x - dot2.x
         abs(self.polygon[d[0]][0][1]-self.polygon[d[1]][0][1])    # dot1.y - dot2.y
     )
     
     for cut in cuts:
         poly1len = len(self.polygon) - cut[1] + cut[0]
         poly2len = cut[1] - cut[0]
         
         # A panel should have at least three edges
         if min(poly1len,poly2len) <= 2:
             continue
         
         # Construct two subpolygons by distributing the dots around our cut (our close dots)
         poly1 = np.zeros(shape=(poly1len,1,2), dtype=int)
         poly2 = np.zeros(shape=(poly2len,1,2), dtype=int)
         
         x = y = 0
         for i in range(len(self.polygon)):
             if i <= cut[0] or i > cut[1]:
                 poly1[x][0] = self.polygon[i]
                 x += 1
             else:
                 poly2[y][0] = self.polygon[i]
                 y += 1
         
         panel1 = Panel(polygon=poly1)
         panel2 = Panel(polygon=poly2)
         
         # Check that subpanels' width and height are not too small
         wh_ok = True
         for p in [panel1,panel2]:
             if p.h / self.h < 0.1:
                 wh_ok = False
             if p.w / self.w < 0.1:
                 wh_ok = False
         
         if not wh_ok:
             continue
         
         # Check that subpanels' area is not too small
         area1 = cv.contourArea(poly1)
         area2 = cv.contourArea(poly2)
         
         if max(area1,area2) == 0:
             continue
         
         areaRatio = min(area1,area2) / max(area1,area2)
         if areaRatio < 0.1:
             continue
         
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
