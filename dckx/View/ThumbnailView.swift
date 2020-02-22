//
//  ThumbnailView.swift
//  dckx
//
//  Created by Vito Royeca on 2/21/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//

import SwiftUI

struct ThumbnailView: View {
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let lightBlueColor = Color(red: 36.0/255.0, green: 158.0/255.0, blue: 235.0/255.0, opacity: 1.0)
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading){
                HStack{
                    Text("username")
                        .foregroundColor(self.lightBlueColor)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                    
                    Button(action: {}){
                        Image("arrow-down")
                        .resizable()
                        .frame(width: 10, height: 10)
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
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

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView()
    }
}
