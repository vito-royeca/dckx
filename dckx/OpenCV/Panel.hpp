//
//  Panel.hpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#ifndef Panel_hpp
#define Panel_hpp

#include <opencv2/opencv.hpp>

using namespace cv;

class Page;
class Segment;

#include "Page.hpp"
#include "Segment.hpp"

class Panel {
public:
    Page *page;
    int x, y, r, b;
    std::vector<cv::Point> polygon;
    bool splittable;
    std::vector<Segment> segments;
    float coverage;

    Panel(Page* page,
          cv::Rect* xywh,
          std::vector<cv::Point>* polygon = nullptr,
          bool splittable = true);

    static Panel fromXyrb(Page* page, int x, int y, int r, int b);
    cv::Rect toXywh();

    Panel overlapPanel(const Panel& other) const ;

    int overlapArea(const Panel& other) const;

    bool overlaps(const Panel& other) const;

    bool contains(const Panel& other) const;

    bool sameRow(const Panel& other) const;

    bool sameCol(const Panel& other) const;

    std::unique_ptr<Panel> findTopPanel() const;

    std::unique_ptr<Panel> findBottomPanel() const;

    std::unique_ptr<Panel> findLeftPanel() const;
    
    std::vector<std::unique_ptr<Panel>> findAllLeftPanels() const ;

    std::unique_ptr<Panel> findRightPanel() const;

    std::vector<std::unique_ptr<Panel>> findAllRightPanels() const ;

    std::unique_ptr<Panel> findNeighbourPanel(const char d) const;

    Panel groupWith(const Panel& other) const;

    Panel merge(const Panel& other) const;

    bool isClose(const Panel& other) const;

    bool bumpsInto(const std::vector<Panel>& otherPanels) const;

    bool containsSegment(const Segment& segment) const;

    std::vector<Segment> getSegments();

    Panel split();

    Panel cachedSplit();

    int w() const;

    int h() const;

    Segment diagonal() const;

    float wt() const;

    float ht() const;

    bool operator==(const Panel& other) const;

    bool operator!=(const Panel& other) const;

    bool operator<(const Panel& other) const;

    bool operator<=(const Panel& other) const;

    bool operator>(const Panel& other) const;

    bool operator>=(const Panel& other) const;

    int area() const;

    std::string to_string() const;

    size_t hash() const;

    bool isSmall(const float extraRatio = 1) const;

    bool isVerySmall() const;
};

class Split {
public:
    Panel panel;
    std::vector<Panel> subpanels;
    Segment segment;
    std::vector<Segment> matchingSegments;
    float coveredDist;

    Split(Panel& panel,
          Panel& subpanel1,
          Panel& subpanel2,
          Segment& splitSegment)
        : panel(panel), subpanels({subpanel1, subpanel2}), segment(splitSegment), coveredDist(0) {
        matchingSegments = segment.intersectAll(panel.getSegments());
        for (const auto& matchingSegment : matchingSegments) {
            coveredDist += matchingSegment.dist();
        }
    }

    bool operator==(const Split& other) const {
        return segment == other.segment;
    }

    bool operator!=(const Split& other) const {
        return segment != other.segment;
    }
    
    float segmentsCoverage() {
        float segmentDist = segment.dist();
        return segmentDist ? coveredDist / segmentDist : 0;
    }
};

#endif /* Panel_hpp */
