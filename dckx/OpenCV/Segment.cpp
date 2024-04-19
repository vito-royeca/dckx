//
//  Segment.cpp
//  dckx
//
//  Created by Vito Royeca on 4/18/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#include "Segment.hpp"

Segment* Segment::alongPolygon(std::vector<std::pair<int, int>> polygon, int i, int j) {
    std::pair<int, int> dot1 = polygon[i];
    std::pair<int, int> dot2 = polygon[j];
    Segment* split_segment = new Segment(dot1, dot2);

    while (true) {
        i = (i - 1) % polygon.size();
        Segment* add_segment = new Segment(polygon[i], polygon[(i + 1) % polygon.size()]);
        
        if (add_segment->angleOkWith(split_segment)) {
            split_segment = new Segment(add_segment->a, split_segment->b);
        } else {
            break;
        }
    }

    while (true) {
        j = (j + 1) % polygon.size();
        Segment* add_segment = new Segment(polygon[(j - 1 + polygon.size()) % polygon.size()], polygon[j]);
        if (add_segment->angleOkWith(split_segment)) {
            split_segment = new Segment(split_segment->a, add_segment->b);
        } else {
            break;
        }
    }

    return split_segment;
}

std::vector<Segment> Segment::unionAll(std::vector<Segment> segments) {
    bool unioned_segments = true;

    while (unioned_segments) {
        unioned_segments = false;
        std::vector<Segment> dedup_segments;
        std::vector<Segment> used;

        for (size_t i = 0; i < segments.size(); ++i) {
            for (size_t j = i + 1; j < segments.size(); ++j) {
                if (std::find(used.begin(), used.end(), segments[j]) != used.end())
                    continue;

                Segment* s3 = segments[i].unionWith(&segments[j]);
                if (s3 != nullptr) {
                    unioned_segments = true;
                    dedup_segments.push_back(*s3);
                    used.push_back(segments[i]);
                    used.push_back(segments[j]);
                    delete s3;
                    break;
                }
            }
            if (std::find(used.begin(), used.end(), segments[i]) == used.end())
                dedup_segments.push_back(segments[i]);
        }
        segments = dedup_segments;
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

    std::pair<int, int> projectedC = projectedPoint(other->a);
    double distCToAB = Segment(other->a, projectedC).dist();

    std::pair<int, int> projectedD = projectedPoint(other->b);
    double distDToAB = Segment(other->b, projectedD).dist();

    if ((distCToAB + distDToAB) / 2 > gutter) {
        return nullptr;
    }

    std::vector<std::pair<int, int>> sortedDots = {a, b, other->a, other->b};
    std::sort(sortedDots.begin(), sortedDots.end(), [](const std::pair<int, int>& a, const std::pair<int, int>& b) {
        return a.first + a.second < b.first + b.second;
    });
    std::pair<int, int> b = sortedDots[1];
    std::pair<int, int> c = sortedDots[2];

    return new Segment(b, c);
}

Segment* Segment::unionWith(Segment* other) {
    Segment* intersect = intersectWith(other);

    if (intersect == nullptr) {
        return nullptr;
    }

    std::vector<std::pair<int, int>> dots = {a, b, other->a, other->b};
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

std::pair<int, int> Segment::projectedPoint(std::pair<int, int> p) const {
    std::pair<int, int> ap = {p.first - a.first, p.second - a.second};
    std::pair<int, int> ab = {b.first - a.first, b.second - a.second};
    double t = (double)(ap.first * ab.first + ap.second * ab.second) / (ab.first * ab.first + ab.second * ab.second);
    return {a.first + (int)(ab.first * t), a.second + (int)(ab.second * t)};
}

