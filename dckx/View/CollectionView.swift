//
//  CollectionView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

struct  CollectionView: View {
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading){
                HStack{
                    Button(action: {}){
                        Image("menu")
                        .resizable()
                        .frame(width: 20, height: 20)
                    }
                    .padding()
                }
                .frame(height: 50)
                .padding(.leading, 10)
            }
        }
        
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
         CollectionView()
    }
}
