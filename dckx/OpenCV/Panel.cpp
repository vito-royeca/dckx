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
    std::vector<Panel> panels;
    
    return panels;
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

