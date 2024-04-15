//
//  ComicItemSource.swift
//  dckx
//
//  Created by Vito Royeca on 4/14/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SDWebImage

class ComicItemSource: NSObject,  UIActivityItemSource {
    var comic: ComicModel?
    
    init(comic: ComicModel?) {
        self.comic = comic
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "\(title())\n\(author())"
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return image()
    }
    
    func title() -> String {
        if let comic = comic {
            return "#\(comic.num): \(comic.title)"
        } else {
            return author()
        }
    }
    
    func author() -> String {
        return "via @dckx - an xkcd comics reader app"
    }
    
    func image() -> UIImage? {
        guard let comic = comic,
            let image = SDImageCache.shared.imageFromCache(forKey: comic.img) else {
            return nil
        }

        return image
    }
}

