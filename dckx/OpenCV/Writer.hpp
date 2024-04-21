//
//  Writer.hpp
//  dckx
//
//  Created by Vito Royeca on 4/20/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef Writer_hpp
#define Writer_hpp

#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

class Page;
class Panel;
class Segment;

#include "Page.hpp"
#include "Panel.hpp"
#include "Segment.hpp"

class Writer {
public:
    void writerPanels(Page* page) const;
};

#endif /* Writer_hpp */
