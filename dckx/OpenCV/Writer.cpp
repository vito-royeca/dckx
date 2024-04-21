//
//  Writer.cpp
//  dckx
//
//  Created by Vito Royeca on 4/20/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

#include <filesystem>

#include "Writer.hpp"

namespace fs = std::__fs::filesystem;

void Writer::writerPanels(Page* page) const {
    fs::path p(page->filename);
    string sep = "/";
    string root = p.parent_path();
    string dir = root + sep + string(p.stem()) + "_panels";
    string ext = string(p.extension());
    
    try {
        if (!fs::exists(dir)) {
            fs::create_directory(dir);
        }
    } catch(const std::exception& e){
        std::cerr << e.what() << '\n';
    }
    
    for (size_t i = 0; i < page->panels.size(); ++i) {
        Panel panel = page->panels[i];
        Rect rect = panel.toXywh();
        Mat panelImage = page->image(Range(rect.y,rect.y+rect.height), Range(rect.x,rect.x+rect.width));
        string panelFilename = dir + sep + std::to_string(i) + ext;
        
        imwrite(panelFilename, panelImage);
        page->panelFiles.push_back(panelFilename);
    }
}
