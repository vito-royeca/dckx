//
//  ComicsData.hpp
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#ifndef ComicsData_hpp
#define ComicsData_hpp

#include <string>
#include <vector>

#pragma once

using namespace std;

class ComicsData {
public:
    vector<int> size;
    vector<int> gutters;
    std::string background;
    vector<vector<int>> panels;
    
    ComicsData splitComics(std::string path, float ratio);
private:
    ComicsData(vector<int> s, vector<int> gs, std::string bg, vector<vector<int>> ps) :
    size{s}, gutters{gs}, background{bg}, panels{ps} {}
};

#endif /* ComicsData_hpp */
