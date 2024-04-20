//
//  Panel.cpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#include <iostream>
#include <stdexcept>

#include "Panel.hpp"

Panel::Panel(Page* page,
             Rect* xywh,
             std::vector<Point2f>* polygon,
             bool splittable) {
    this->page = page;
    
    if (xywh == nullptr && polygon == nullptr) {
        throw std::invalid_argument("Fatal error: no parameter to define Panel boundaries");
    }
    
    if (xywh == nullptr) {
        Rect newXywh = cv::boundingRect(*polygon);
        this->x = newXywh.x;
        this->y = newXywh.y;
        this->r = this->x + newXywh.width;
        this->b = this->y + newXywh.height;
    } else {
        this->x = xywh->x;
        this->y = xywh->y;
        this->r = this->x + xywh->width;
        this->b = this->y + xywh->height;
    }
    
    this->polygon = *polygon;
    this->splittable = splittable;
}

Panel Panel::fromXyrb(Page* page, int x, int y, int r, int b) {
    Rect rect(x, y, r - x, b - y);
    return Panel(page, &rect);
}

Panel Panel::overlapPanel(const Panel& other) const {
    
    if (x > other.r || other.x > r) {
        Rect rect = {};
        return Panel(page, &rect);
    }
    if (y > other.b || other.y > b) {
        Rect rect = {};
        return Panel(page, &rect);
    }
    
    int overlapX = std::max(x, other.x);
    int overlapY = std::max(y, other.y);
    int overlapR = std::min(r, other.r);
    int overlapB = std::min(b, other.b);
    Rect rect(overlapX, overlapY, overlapR - overlapX, overlapB - overlapY);
    
    return Panel(page, &rect);
}

int Panel::overlapArea(const Panel& other) const {
    Panel opanel = overlapPanel(other);

    if (opanel.x == 0 && opanel.y == 0 && opanel.r == 0 && opanel.b == 0) {
        return 0;
    }
    return opanel.area();
}

bool Panel::overlaps(const Panel& other) const {
    Panel opanel = overlapPanel(other);
    float areaRatio = 0.1;
    int smallestPanelArea = std::min(area(), other.area());
    
    if (smallestPanelArea == 0) {
        return true;
    }
    return opanel.area() / smallestPanelArea > areaRatio;
}

bool Panel::contains(const Panel& other) const {
    Panel opanel = overlapPanel(other);
    
    if (opanel.x == 0 && opanel.y == 0 && opanel.r == 0 && opanel.b == 0) {
        return false;
    }
    return opanel.area() / other.area() > 0.50;
}

bool Panel::sameRow(const Panel& other) const {
    Panel above = y < other.y ? *this : other;
    Panel below = y < other.y ? other : *this;

    if (below.y > above.b) {
        return false;
    }
    if (below.b < above.b) {
        return true;
    }

    int intersectionY = std::min(above.b, below.b) - below.y;
    return intersectionY / std::min(above.h(), below.h()) >= 1 / 3.0;
}

bool Panel::sameCol(const Panel& other) const {
    Panel left = x < other.x ? *this : other;
    Panel right = x < other.x ? other : *this;

    if (right.x > left.r) {
        return false;
    }
    if (right.r < left.r) {
        return true;
    }

    int intersectionX = std::min(left.r, right.r) - right.x;
    return intersectionX / std::min(left.w(), right.w()) >= 1 / 3.0;
}

Panel Panel::findTopPanel() const {
    std::vector<Panel> allTop;

    for (auto& p : page->panels) {
        if (p.b <= y && p.sameCol(*this)) {
            allTop.push_back(p);
        }
    }

    return *std::max_element(allTop.begin(), allTop.end(), [](const Panel& p1, const Panel& p2) {
        return p1.b < p2.b;
    });
}

Panel Panel::findBottomPanel() const {
    std::vector<Panel> allBottom;
    
    for (auto& p : page->panels) {
        if (p.y >= b && p.sameCol(*this)) {
            allBottom.push_back(p);
        }
    }

    return *std::min_element(allBottom.begin(), allBottom.end(), [](const Panel& p1, const Panel& p2) {
        return p1.y < p2.y;
    });
}

std::vector<Panel> Panel::findAllLeftPanels() const {
    std::vector<Panel> allLeft;

    for (auto& p : page->panels) {
        if (p.r <= x && p.sameRow(*this)) {
            allLeft.push_back(p);
        }
    }

    return allLeft;
}

Panel Panel::findLeftPanel() const {
    std::vector<Panel> allLeft = findAllLeftPanels();

    return *std::max_element(allLeft.begin(), allLeft.end(), [](const Panel& p1, const Panel& p2) {
        return p1.r < p2.r;
    });
}

std::vector<Panel> Panel::findAllRightPanels() const {
    std::vector<Panel> allRight;

    for (auto& p : page->panels) {
        if (p.x >= r && p.sameRow(*this)) {
            allRight.push_back(p);
        }
    }

    return allRight;
}

Panel Panel::findRightPanel() const {
    std::vector<Panel> allRight = findAllRightPanels();

    return *std::min_element(allRight.begin(), allRight.end(), [](Panel& p1, Panel& p2) {
        return p1.x < p2.x;
    });
}

Panel Panel::findNeighbourPanel(const char d) const {
    switch (d) {
        case 'x':
            return findLeftPanel();
        case 'y':
            return findTopPanel();
        case 'r':
            return findRightPanel();
        case 'b':
            return findBottomPanel();
        default:
            return findLeftPanel();
    }
}

Panel Panel::groupWith(const Panel& other) const {
    int minX = std::min(x, other.x);
    int minY = std::min(y, other.y);
    int maxR = std::max(r, other.r);
    int maxB = std::max(b, other.b);
    Rect rect(minX, minY, maxR - minX, maxB - minY);

    return Panel(page, &rect);
}

Panel Panel::merge(const Panel& other) const {
    std::vector<Panel> possiblePanels = { *this };

    if (other.x < x) {
        possiblePanels.push_back(Panel::fromXyrb(page, other.x, y, r, b));
    }

    if (other.r > r) {
        for (const auto& pp : possiblePanels) {
            possiblePanels.push_back(Panel::fromXyrb(page, pp.x, pp.y, other.r, pp.b));
        }
    }

    if (other.y < y) {
        for (const auto& pp : possiblePanels) {
            possiblePanels.push_back(Panel::fromXyrb(page, pp.x, other.y, pp.r, pp.b));
        }
    }

    if (other.b > b) {
        for (const auto& pp : possiblePanels) {
            possiblePanels.push_back(Panel::fromXyrb(page, pp.x, pp.y, pp.r, other.b));
        }
    }

    std::vector<Panel> otherPanels;
    for (auto& p : page->panels) {
        if (p != *this && p != other) {
            otherPanels.push_back(p);
        }
    }
    possiblePanels.erase(std::remove_if(possiblePanels.begin(), possiblePanels.end(),
                                        [&](Panel& p) { return p.bumpsInto(otherPanels); }),
                         possiblePanels.end());

    return *std::max_element(possiblePanels.begin(), possiblePanels.end(), [](Panel& p1, Panel& p2) {
        return p1.area() < p2.area();
    });
}

bool Panel::isClose(const Panel& other) const {
    float c1x = x + w() / 2.0;
    float c1y = y + h() / 2.0;
    float c2x = other.x + other.w() / 2.0;
    float c2y = other.y + other.h() / 2.0;
    return std::abs(c1x - c2x) <= (w() + other.w()) * 0.75 &&
           std::abs(c1y - c2y) <= (h() + other.h()) * 0.75;
}

bool Panel::bumpsInto(const std::vector<Panel>& otherPanels) const {
    for (auto& other : otherPanels) {
        if (other == *this) {
            continue;
        }
        if (overlaps(other)) {
            return true;
        }
    }

    return false;
}

bool Panel::containsSegment(const Segment& segment) const {
    std::vector<int> xyrb = segment.toXyrb();
    Panel other = Panel::fromXyrb(NULL, xyrb[0], xyrb[1], xyrb[2], xyrb[3]);

    return overlaps(other);
}

std::vector<Segment> Panel::getSegments() {
    if (!segments.empty()) {
        return segments;
    }

    for (const auto& segment : page->segments) {
        if (containsSegment(segment)) {
            segments.push_back(segment);
        }
    }
    return segments;
}

Panel Panel::split() {
    if (!splittable) {
        Rect rect = {};
        return Panel(page, &rect);
    }

    Panel split = cachedSplit();
    if (split.x == 0 && split.y == 0 && split.r == 0 && split.b == 0) {
        splittable = false;
    }

    return split;
}

Panel Panel::cachedSplit() {
    if (polygon.empty()) {
        Rect rect = {};
        return Panel(page, &rect);
    }
    if (isSmall(2)) {
        Rect rect = {};
        return Panel(page, &rect);
    }

    int minHops = 3;
    int maxDistX = w() / 3;
    int maxDistY = h() / 3;
    float maxDiagonal = std::sqrt(maxDistX * maxDistX + maxDistY * maxDistY);
    float dotsAlongLinesDist = maxDiagonal / 5;
    float minDistBetweenDotsX = maxDistX / 10.0;
    float minDistBetweenDotsY = maxDistY / 10.0;

    std::vector<Point2f> originalPolygon = polygon;
    std::vector<Point2f> composedPolygon;
    std::vector<Point2f> intermediaryDots;
    std::vector<Point2f> extraDots;

    for (size_t i = 0; i < originalPolygon.size(); ++i) {
        size_t j = (i + 1) % originalPolygon.size();
        Point2f dot1 = originalPolygon[i];
        Point2f dot2 = originalPolygon[j];
        Segment seg(dot1, dot2);

        if (seg.distX() < minDistBetweenDotsX && seg.distY() < minDistBetweenDotsY) {
            originalPolygon[j] = seg.center();
            continue;
        }

        composedPolygon.push_back(dot1);

        std::vector<Point2f> addDots;

        if (seg.dist() < dotsAlongLinesDist * 2) {
            continue;
        }

        for (size_t k = 0; k < originalPolygon.size(); ++k) {
            if (std::abs(static_cast<int>(k) - static_cast<int>(i)) < minHops) {
                continue;
            }
            Point2f dot3 = originalPolygon[k];
            Point2f projectedDot3 = seg.projectedPoint(dot3);
            Segment project(dot3, projectedDot3);

            if (!seg.mayContain(projectedDot3) ||
                project.distX() > maxDistX || project.distY() > maxDistY) {
                continue;
            }
            addDots.push_back(projectedDot3);
            intermediaryDots.push_back(projectedDot3);
        }

        float alphaX = std::acos(seg.distX(true) / seg.dist());
        float alphaY = std::asin(seg.distY(true) / seg.dist());
        int distX = std::cos(alphaX) * dotsAlongLinesDist;
        int distY = std::sin(alphaY) * dotsAlongLinesDist;

        Point2f dot1b(dot1.x + distX, dot1.y + distY);
        if (intermediaryDots.empty() ||
            Segment(dot1b, intermediaryDots[0]).dist() > dotsAlongLinesDist) {
            addDots.push_back(dot1b);
            extraDots.push_back(dot1b);
        }

        Point2f dot2b(dot2.x - distX, dot2.y - distY);
        if (intermediaryDots.empty() ||
            Segment(dot2b, intermediaryDots.back()).dist() > dotsAlongLinesDist) {
            addDots.push_back(dot2b);
            extraDots.push_back(dot2b);
        }

        for (const auto& dot : addDots) {
            composedPolygon.push_back(dot);
        }
    }

    originalPolygon = composedPolygon;
    composedPolygon.clear();

    for (size_t i = 0; i < originalPolygon.size(); ++i) {
        size_t j = (i + 1) % originalPolygon.size();
        Point2f dot1 = originalPolygon[i];
        Point2f dot2 = originalPolygon[j];
        Segment seg(dot1, dot2);

        if (seg.distX() < minDistBetweenDotsX && seg.distY() < minDistBetweenDotsY) {
            intermediaryDots.erase(std::remove(intermediaryDots.begin(), intermediaryDots.end(), dot1),
                                   intermediaryDots.end());
            intermediaryDots.erase(std::remove(intermediaryDots.begin(), intermediaryDots.end(), dot2),
                                    intermediaryDots.end());
            originalPolygon[j] = seg.center();
            continue;
        }

        composedPolygon.push_back(dot1);
    }

    std::vector<std::vector<int>> nearbyDots;
    for (size_t i = 0; i < composedPolygon.size() - minHops; ++i) {
        for (size_t j = i + minHops; j < composedPolygon.size(); ++j) {
            Point2f dot1 = composedPolygon[i];
            Point2f dot2 = composedPolygon[j];
            Segment seg(dot1, dot2);
            
            if (seg.distX() <= maxDistX && seg.distY() <= maxDistY) {
                nearbyDots.push_back({static_cast<int>(i), static_cast<int>(j)});
            }
        }
    }

    if (nearbyDots.empty()) {
        Rect rect = {};
        return Panel(page, &rect);
    }

    std::vector<Split> splits;
    for (const auto& dots : nearbyDots) {
        int poly1len = static_cast<int>(composedPolygon.size()) - dots[1] + dots[0];
        int poly2len = dots[1] - dots[0];
        if (std::min(poly1len, poly2len) <= 2) {
            continue;
        }
        std::vector<Point2f> poly1(poly1len);
        std::vector<Point2f> poly2(poly2len);
        int x = 0, y = 0;
        for (size_t i = 0; i < composedPolygon.size(); ++i) {
            if (i <= dots[0] || i > dots[1]) {
                poly1[x++] = composedPolygon[i];
            } else {
                poly2[y++] = composedPolygon[i];
            }
        }
        Panel panel1(page, nullptr, &poly1);
        Panel panel2(page, nullptr, &poly2);
        if (panel1.isSmall() || panel2.isSmall()) {
            continue;
        }
        if (panel1 == *this || panel2 == *this) {
            continue;
        }
        if (panel1.overlaps(panel2)) {
            continue;
        }
        
        Segment splitSegment(composedPolygon[dots[0]], composedPolygon[dots[1]]);
        Split split(*this, panel1, panel2, splitSegment);
        if (std::find(splits.begin(), splits.end(), split) == splits.end()) {
            splits.push_back(split);
        }
    }

    splits.erase(std::remove_if(splits.begin(), splits.end(),
                                [](Split& split) { return split.segmentsCoverage() <= 50 / 100.0; }),
                 splits.end());

    if (splits.empty()) {
        Rect rect = {};
        return Panel(page, &rect);
    }

    Split bestSplit = *std::max_element(splits.begin(), splits.end(), [](const Split& split1, const Split& split2) {
        return split1.coveredDist < split2.coveredDist;
    });
    
    return bestSplit.panel;
}

int Panel::w() const {
    return r - x;
}

int Panel::h() const {
    return b - y;
}

Segment Panel::diagonal() const {
    return Segment(Point2f(x, y), Point2f(r, b));
}

float Panel::wt() const {
    return w() / 10.0;
}

float Panel::ht() const {
    return h() / 10.0;
}

Rect Panel::toXywh() {
    return Rect(x, y, w(), h());
}

bool Panel::operator==(const Panel& other) const{
    return std::abs(x - other.x) < wt() &&
           std::abs(y - other.y) < ht() &&
           std::abs(r - other.r) < wt() &&
           std::abs(b - other.b) < ht();
}

bool Panel::operator!=(const Panel& other) const{
    return !(*this == other);
}

bool Panel::operator<(const Panel& other) const {
    if (other.y >= b - ht() && other.y >= y - ht()) {
        return true;
    }
    if (y >= other.b - ht() && y >= other.y - ht()) {
        return false;
    }
    if (other.x >= r - wt() && other.x >= x - wt()) {
        return true;
    }
    if (x >= other.r - wt() && x >= other.x - wt()) {
        return false;
    }
    return true;
}

bool Panel::operator<=(const Panel& other) const {
    return *this < other;
}

bool Panel::operator>=(const Panel& other) const {
    return !(*this < other);
}

int Panel::area() const {
    return w() * h();
}

std::string Panel::to_string() const {
    return std::to_string(x) + "x" + std::to_string(y) + "-" + std::to_string(r) + "x" + std::to_string(b);
}

size_t Panel::hash() const {
    return std::hash<std::string>{}(to_string());
}

bool Panel::isSmall(const float extraRatio) const {
    return w() < page->imageSize[0] * page->smallPanelRatio * extraRatio ||
           h() < page->imageSize[1] * page->smallPanelRatio * extraRatio;
}

bool Panel::isVerySmall() const {
    return isSmall(1 / 10.0);
}
