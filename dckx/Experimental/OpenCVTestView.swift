//
//  OpenCVTestView.swift
//  dckx
//
//  Created by Vito Royeca on 4/18/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct OpenCVTestView: View {
    @State var viewModel: ComicViewModel
    @State private var panelsModel: ComicPanelsModel
    
    init(modelContext: ModelContext) {
        let model = ComicViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: model)
        panelsModel = ComicPanelsModel()
    }
    
    var body: some View {
        NavigationView {
            displayView
                .navigationTitle(viewModel.comicTitle)
                .toolbar {
                    NavigationToolbar(delegate: viewModel)
                }
        }
    }
    
    var displayView: some View {
        GeometryReader { proxy in
            List {
                LabeledContent("OpenCV Version",
                               value: OpenCVWrapper.getOpenCVVersion())
                
                LabeledContent("File",
                               value: panelsModel.filenameLastPath)
                
                LabeledContent("Size",
                               value: "width: \(panelsModel.width), height: \(panelsModel.height)")
                
                Section("Image") {
                    InteractiveImageView(url: viewModel.currentComic?.imageURL,
                                         reloadAction: viewModel.reloadComic,
                                         successAction: testOpenCV)
                        .frame(height: proxy.size.height / 2)
                }
                
                Section("Panels") {
                    ForEach(panelsModel.panels) { panel in
                        VStack(alignment: .leading) {
                            WebImage(url: URL(fileURLWithPath: panel.filename))
                                .resizable()
                                .scaledToFit()
                                .frame(height: proxy.size.height / 4)
                            LabeledContent("Coordinates",
                                           value: "\(panel.rect)")
                        }
                    }
                }
            }
        }
    }
    
    func testOpenCV() {
        panelsModel = ComicPanelsModel()
        
        DispatchQueue.global(qos: .background).async {
            if let url = viewModel.currentComic?.imageURL,
               let fileName = SDImageCache.shared.cachePath(forKey: "\(url)") {
                
                var maxSleep = 0
                repeat {
                    sleep(1)
                    print("sleeping... \(maxSleep)")
                    maxSleep += 1
                } while (!FileManager.default.fileExists(atPath: fileName))

                OpenCVWrapper.split(fileName, 1) { dictionary in
                    DispatchQueue.main.async {
                        panelsModel = ComicPanelsModel(using: dictionary)
                    }
                }
            }
        }
        
    }
}

#Preview {
    OpenCVTestView(modelContext: try! ModelContainer(for: ComicModel.self).mainContext)
}
