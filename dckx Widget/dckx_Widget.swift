//
//  dckx_Widget.swift
//  dckx Widget
//
//  Created by Vito Royeca on 4/20/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import WidgetKit
import SwiftUI
import CoreData
import PromiseKit

struct Provider: TimelineProvider {
//    init () {
//        Database.sharedInstance.copyDatabase()
//    }

    func fetchLastComic() -> Comic {
        do {
            let sensitiveData = SensitiveData()
            let request: NSFetchRequest<NSFetchRequestResult> = Comic.fetchRequest()
            request.fetchLimit = 1
            request.sortDescriptors = [NSSortDescriptor(key: "num", ascending: false)]
            request.predicate = sensitiveData.createComicsPredicate(basePredicate: nil)
            
            let dataStack = CoreData.sharedInstance.dataStack
            
            guard let array = try dataStack.execute(request, with: dataStack.mainContext) as? [NSManagedObject],
                let comic = array.first as? Comic else {
                
                let error = NSError(domain: "",
                                    code: 404,
                                    userInfo: [NSLocalizedDescriptionKey: "Last Comic not found."])
                throw(error)
            }
            
            return comic
        }
        catch {
            fatalError()
        }
    }
    
    func fetchComic(num: Int32) -> Comic {
        do {
            let dataStack = CoreData.sharedInstance.dataStack
            
            if let comic = try dataStack.fetch(num, inEntityNamed: String(describing: Comic.self)) as? Comic {
                return comic
            } else {
                let error = NSError(domain: "",
                                    code: 404,
                                    userInfo: [NSLocalizedDescriptionKey: "Comic with ID \(num) not found."])
                throw(error)
            }
        } catch {
            fatalError()
        }
    }
    
//    func fetchRandomComic() -> Comic {
//        let comic = fetchLastComic()
//        let random = Int.random(in: 0 ... Int(comic.num))
//        return fetchComic(num: Int32(random))
//    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), comic: fetchLastComic())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), comic: fetchLastComic())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let comic = fetchLastComic()
        let currentDate = Date()
        var entries: [SimpleEntry] = []

        for _ in 0 ..< 5 {
            let random = Int.random(in: 0 ... Int(comic.num))
            let entry = SimpleEntry(date: currentDate, comic: fetchComic(num: Int32(random)))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let comic: Comic?
}

struct PlaceholderView : View {
  var body: some View {
    Text("Placeholder View")
  }
}

struct dckx_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        dckxWidgetView(urlString: entry.comic?.img ?? "")
    }
}

@main
struct dckx_Widget: Widget {
    let kind: String = "dckx_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider()/*,
                            placeholder: PlaceholderView()*/) { entry in
            dckx_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Random Comic")
        .description("Display random xkcd comic.")
        .supportedFamilies([.systemSmall])
    }
}

//struct dckx_Widget_Previews: PreviewProvider {
//    static var previews: some View {
//        dckx_WidgetEntryView(entry: SimpleEntry(comic: ComicFetcher().currentComic))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
