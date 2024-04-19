//
//  Segment.hpp
//  dckx
//
//  Created by Vito Royeca on 4/18/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef Segment_hpp
#define Segment_hpp

#include <cmath>
#include <algorithm>
#include <vector>
#include <tuple>

class Segment {
public:
    std::pair<int, int> a, b;

    Segment(std::pair<int, int> a, std::pair<int, int> b) : a(a), b(b) {}

    static Segment* alongPolygon(std::vector<std::pair<int, int>> polygon, int i, int j);
    static std::vector<Segment> unionAll(std::vector<Segment> segments);
    
    Segment* intersectWith(Segment* other);
    Segment* unionWith(Segment* other);
    std::vector<Segment> intersectAll(std::vector<Segment> segments);
    std::pair<int, int> projectedPoint(std::pair<int, int> p) const;
    
    std::string toString() {
        return "(" + std::to_string(a.first) + ", " + std::to_string(a.second) + "), (" + std::to_string(b.first) + ", " + std::to_string(b.second) + ")";
    }

    bool operator==(const Segment& other) {
        return (a == other.a && b == other.b) || (a == other.b && b == other.a);
    }
    
    double dist() const {
        return std::sqrt(distX(true) * distX(true) + distY(true) * distY(true));
    }

    int distX(bool keep_sign = false) const {
        int dist = b.first - a.first;
        return keep_sign ? dist : std::abs(dist);
    }

    int distY(bool keep_sign = false) const {
        int dist = b.second - a.second;
        return keep_sign ? dist : std::abs(dist);
    }

    int left() const {
        return std::min(a.first, b.first);
    }

    int top() const {
        return std::min(a.second, b.second);
    }

    int right() const {
        return std::max(a.first, b.first);
    }

    int bottom() const {
        return std::max(a.second, b.second);
    }

    std::vector<int> toXyrb() const {
        return {left(), top(), right(), bottom()};
    }

    std::pair<int, int> center() const {
        return {left() + distX() / 2, top() + distY() / 2};
    }

    bool mayContain(std::pair<int, int> dot) const {
        return dot.first >= left() && dot.first <= right() && dot.second >= top() && dot.second <= bottom();
    }

    double angleWith(Segment* other) const {
        return std::abs(angle() - other->angle()) * 180.0 / M_PI;
    }

    bool angleOkWith(Segment* other) const {
        double angle_diff = angleWith(other);
        return angle_diff < 10 || std::abs(angle_diff - 180) < 10;
    }

    double angle() const {
        return distX() != 0 ? std::atan2(distY(true), distX(true)) : M_PI / 2;
    }
};




#endif /* Segment_hpp */
