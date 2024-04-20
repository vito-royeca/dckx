//
//  Segment.cpp
//  dckx
//
//  Created by Vito Royeca on 4/18/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#include "Segment.hpp"

Segment* Segment::alongPolygon(std::vector<Point2f> polygon, int i, int j) {
    Point2f dot1 = polygon[i];
    Point2f dot2 = polygon[j];
    Segment* splitSegment = new Segment(dot1, dot2);

    while (true) {
        i = (i - 1) % polygon.size();
        Segment* addSegment = new Segment(polygon[i], polygon[(i + 1) % polygon.size()]);
        
        if (addSegment->angleOkWith(splitSegment)) {
            splitSegment = new Segment(addSegment->a, splitSegment->b);
        } else {
            break;
        }
    }

    while (true) {
        j = (j + 1) % polygon.size();
        Segment* addSegment = new Segment(polygon[(j - 1 + polygon.size()) % polygon.size()], polygon[j]);
        if (addSegment->angleOkWith(splitSegment)) {
            splitSegment = new Segment(splitSegment->a, addSegment->b);
        } else {
            break;
        }
    }

    return splitSegment;
}

std::vector<Segment> Segment::unionAll(std::vector<Segment> segments) {
    bool unionedSegments = true;

    while (unionedSegments) {
        unionedSegments = false;
        std::vector<Segment> dedupSegments;
        std::vector<Segment> used;

        for (size_t i = 0; i < segments.size(); ++i) {
            for (size_t j = i + 1; j < segments.size(); ++j) {
                if (std::find(used.begin(), used.end(), segments[j]) != used.end())
                    continue;

                Segment* s3 = segments[i].unionWith(&segments[j]);
                if (s3 != nullptr) {
                    unionedSegments = true;
                    dedupSegments.push_back(*s3);
                    used.push_back(segments[i]);
                    used.push_back(segments[j]);
                    delete s3;
                    break;
                }
            }
            if (std::find(used.begin(), used.end(), segments[i]) == used.end())
                dedupSegments.push_back(segments[i]);
        }
        segments = dedupSegments;
    }
    return segments;
}

Segment* Segment::intersectWith(Segment* other) {
    double gutter = std::max(dist(), other->dist()) * 5 / 100;

    if (!angleOkWith(other)) {
        return nullptr;
    }

    if (right() < other->left() - gutter ||
        left() > other->right() + gutter ||
        bottom() < other->top() - gutter ||
        top() > other->bottom() + gutter) {
        return nullptr;
    }

    Point2f projectedC = projectedPoint(other->a);
    double distCToAB = Segment(other->a, projectedC).dist();

    Point2f projectedD = projectedPoint(other->b);
    double distDToAB = Segment(other->b, projectedD).dist();

    if ((distCToAB + distDToAB) / 2 > gutter) {
        return nullptr;
    }

    std::vector<Point2f> sortedDots = {a, b, other->a, other->b};
    std::sort(sortedDots.begin(), sortedDots.end(), [](const Point2f& a, const Point2f& b) {
        return a.x + a.y < b.x + b.y;
    });
    Point2f b = sortedDots[1];
    Point2f c = sortedDots[2];

    return new Segment(b, c);
}

Segment* Segment::unionWith(Segment* other) {
    Segment* intersect = intersectWith(other);

    if (intersect == nullptr) {
        return nullptr;
    }

    std::vector<Point2f> dots = {a, b, other->a, other->b};
    dots.erase(std::remove(dots.begin(), dots.end(), intersect->a), dots.end());
    dots.erase(std::remove(dots.begin(), dots.end(), intersect->b), dots.end());
    return new Segment(dots[0], dots[1]);
}

std::vector<Segment> Segment::intersectAll(std::vector<Segment> segments) {
    std::vector<Segment> segmentsMatch;

    for (Segment segment : segments) {
        Segment* s3 = intersectWith(&segment);

        if (s3 != nullptr) {
            segmentsMatch.push_back(*s3);
        }
    }

    return Segment::unionAll(segmentsMatch);
}

Point2f Segment::projectedPoint(Point2f p) const {
    Point2f ap = {p.x - a.x, p.y - a.y};
    Point2f ab = {b.x - a.x, b.y - a.y};
    double t = (double)(ap.x * ab.x + ap.y * ab.y) / (ab.x * ab.x + ab.y * ab.y);
    return { a.x + (int)(ab.x * t), a.y + (int)(ab.y * t) };
}

std::string Segment::to_string() {
    return "(" + std::to_string(a.x) + ", " + std::to_string(a.y) + "), (" + std::to_string(b.x) + ", " + std::to_string(b.y) + ")";
}

bool Segment::operator==(const Segment& other) const {
    return (a == other.a && b == other.b) || (a == other.b && b == other.a);
}

bool Segment::operator!=(const Segment& other) const {
    return (a != other.a && b != other.b) || (a != other.b && b != other.a);
}

double Segment::dist() const {
    return std::sqrt(distX(true) * distX(true) + distY(true) * distY(true));
}

int Segment::distX(bool keepSign) const {
    int dist = b.x - a.x;
    return keepSign ? dist : std::abs(dist);
}

int Segment::distY(bool keepSign) const {
    int dist = b.y - a.y;
    return keepSign ? dist : std::abs(dist);
}

int Segment::left() const {
    return std::min(a.x, b.x);
}

int Segment::top() const {
    return std::min(a.y, b.y);
}

int Segment::right() const {
    return std::max(a.x, b.x);
}

int Segment::bottom() const {
    return std::max(a.y, b.y);
}

std::vector<int> Segment::toXyrb() const {
    return { left(), top(), right(), bottom() };
}

Point2f Segment::center() const {
    Point2f point( left() + distX() / 2, top() + distY() / 2 );
    return point;
}

bool Segment::mayContain(Point2f dot) const {
    return dot.x >= left() && dot.x <= right() && dot.y >= top() && dot.y <= bottom();
}

double Segment::angleWith(Segment* other) const {
    return std::abs(angle() - other->angle()) * 180.0 / M_PI;
}

bool Segment::angleOkWith(Segment* other) const {
    double angleDiff = angleWith(other);
    return angleDiff < 10 || std::abs(angleDiff - 180) < 10;
}

double Segment::angle() const {
    return distX() != 0 ? std::atan2(distY(true), distX(true)) : M_PI / 2;
}
