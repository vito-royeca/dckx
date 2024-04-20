//
//  Page.hpp
//  dckx
//
//  Created by Vito Royeca on 4/19/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef Page_hpp
#define Page_hpp

class Panel;
class Segment;

#include "Panel.hpp"
#include "Segment.hpp"

class Page {
public:
    std::vector<Panel> panels;
    std::vector<Segment> segments;
    std::vector<int> imageSize;
    float smallPanelRatio;
    std::string numbering;
};

#endif /* Page_hpp */
