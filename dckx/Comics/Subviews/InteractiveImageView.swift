//
//  InteractiveImageView.swift
//  dckx
//
//  Created by Vito Royeca on 4/14/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI

struct InteractiveImageView: View {
    @State private var zoomScale: CGFloat = 1
    @State private var previousZoomScale: CGFloat = 1
    private let minZoomScale: CGFloat = 1
    private let maxZoomScale: CGFloat = 5
    
    var url: URL?

    var body: some View {
        GeometryReader { proxy in
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        ProgressView()
                    }
                case .success(let image):
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
                    
                    
                case .failure(let error):
                    Text(error.localizedDescription)
                @unknown default:
                    EmptyView()
                }
            }
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
    InteractiveImageView()
}
