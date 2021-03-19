//
//  HideScrollView.swift
//  dckx
//
//  Created by Vito Royeca on 3/14/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Combine
import SwiftUI

struct HideScrollView: View {
    
    @State var initialOffset: CGFloat?
    @State var offset: CGFloat?
    @State var viewIsShown: Bool = true
    
    var body: some View {
        
        VStack{
            ScrollView {
                
                GeometryReader { geometry in
                    Color.clear.preference(key: OffsetKey.self, value: geometry.frame(in: .global).minY)
                        .frame(height: 0)
                }
                
                ForEach(0 ..< 20) { item in
                    VStack {
                        HStack {
                            Text("Content Items")
                            Spacer()
                        }.padding(.horizontal) .frame(height: 40)
                    }
                }
            }
            HStack {
                Text("Hide Me")
                Spacer()
            }.padding(.horizontal) .frame(height: 60) .background(Color.red) .foregroundColor(Color.white)//.opacity(self.viewIsShown ? 1 : 0)
//            .position(x: self.frame().l, y: -(offset ?? 0))
            
        }.onPreferenceChange(OffsetKey.self) {
            if self.initialOffset == nil || self.initialOffset == 0 {
                self.initialOffset = $0
            }
            
            self.offset = $0
            
            guard let initialOffset = self.initialOffset,
                let offset = self.offset else {
                return
            }
            
                
            if(initialOffset > offset){
                self.viewIsShown = false
                print("hide: \(initialOffset):\(offset)")
            } else {
                self.viewIsShown = true
                print("show \(initialOffset):\(offset)")
            }
        }
        
    }
}

struct OffsetKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?,
                       nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

