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

using namespace cv;

class Segment {
public:
    Point2f a, b;

    Segment(Point2f a,
            Point2f b) : a(a), b(b) {}

    static Segment* alongPolygon(std::vector<Point2f> polygon, int i, int j);

    static std::vector<Segment> unionAll(std::vector<Segment> segments);

    Segment* intersectWith(Segment* other);

    Segment* unionWith(Segment* other);

    std::vector<Segment> intersectAll(std::vector<Segment> segments);

    Point2f projectedPoint(Point2f p) const;
    
    std::string to_string();

    bool operator==(const Segment& other) const;

    bool operator!=(const Segment& other) const;
    
    double dist() const;

    int distX(bool keepSign = false) const;

    int distY(bool keepSign = false) const;

    int left() const;

    int top() const;

    int right() const;

    int bottom() const;

    std::vector<int> toXyrb() const;

    Point2f center() const;

    bool mayContain(Point2f dot) const;

    double angleWith(Segment* other) const;

    bool angleOkWith(Segment* other) const;

    double angle() const;
};

#endif /* Segment_hpp */
