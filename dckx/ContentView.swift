//
//  ContentView.swift
//  dckx
//
//  Created by Vito Royeca on 4/13/24.
//  Copyright © 2024 Vito Royeca. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("\(OpenCVWrapper.getOpenCVVersion())")
    }
}

#Preview {
    ContentView()
}
