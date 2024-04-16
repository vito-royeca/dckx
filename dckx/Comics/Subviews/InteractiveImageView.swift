//
//  InteractiveImageView.swift
//  dckx
//
//  Created by Vito Royeca on 4/14/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct InteractiveImageView: View {
    @State private var zoomScale: CGFloat = 1
    @State private var previousZoomScale: CGFloat = 1
    private let minZoomScale: CGFloat = 1
    private let maxZoomScale: CGFloat = 5
    
    var url: URL?
    var reloadAction: () -> Void

    private let textFont = UserDefaults.standard.bool(forKey: SettingsKey.comicsViewerUseSystemFont) ?
    Font.system(size: 16) : Font.dckxRegularText
    
    var body: some View {
        GeometryReader { proxy in
            WebImage(url: url) { image in
                ScrollView([.vertical, .horizontal],
                           showsIndicators: false) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture(count: 2, perform: onImageDoubleTapped)
                        .gesture(zoomGesture)
                        .frame(width: proxy.size.width * max(minZoomScale, zoomScale))
                        .frame(maxHeight: .infinity)
                }
            } placeholder: {
                ProgressView()
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
    
    var errorView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            HStack {
                Spacer(minLength: 0)
                VStack {
                    Text("Ooops... the image can't be loaded.")
                        .font(textFont)
                    Button(action: reloadAction) {
                        Text("Try again")
                            .font(textFont)
                    }
                }
                Spacer(minLength: 0)
            }

            Spacer()
        }
    }

    var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged(onZoomGestureStarted)
            .onEnded(onZoomGestureEnded)
    }
    
    func resetImageState() {
        withAnimation(.interactiveSpring()) {
            zoomScale = 1
        }
    }

    func onImageDoubleTapped() {
        if zoomScale == 1 {
            withAnimation(.spring()) {
                zoomScale = 5
            }
        } else {
            resetImageState()
        }
    }
    
    func onZoomGestureStarted(value: MagnifyGesture.Value) {
        withAnimation(.easeIn(duration: 0.1)) {
            let delta = value.magnification / previousZoomScale
            previousZoomScale = value.magnification
            let zoomDelta = zoomScale * delta
            var minMaxScale = max(minZoomScale, zoomDelta)
            minMaxScale = min(maxZoomScale, minMaxScale)
            zoomScale = minMaxScale
        }
    }
    
    func onZoomGestureEnded(value: MagnifyGesture.Value) {
        previousZoomScale = 1

        if zoomScale <= 1 {
            resetImageState()
        } else if zoomScale > 5 {
            zoomScale = 5
        }
    }
}

#Preview {
    InteractiveImageView(reloadAction: {})
}
