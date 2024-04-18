//
//  ComicsData.hpp
//  dckx
//
//  Created by Vito Royeca on 4/18/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef ComicsData_hpp
#define ComicsData_hpp

#include <stdio.h>

using namespace std;

class ComicsData {
public:
    string background;
    vector<int> size;
    vector<int> gutters;
    vector<vector<int>> panels;
};

#endif /* ComicsData_hpp */
