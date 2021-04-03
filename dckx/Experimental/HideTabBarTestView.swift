//
//  HideTabBarTestView.swift
//  dckx
//
//  Created by Vito Royeca on 4/2/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI

struct HideTabBarTestView: View {
    @State var tabSelection = "Tab 1"
    @State var searchString = ""
    @State var scopeSelection = 0
    let dataArray = ["John", "Paul", "George", "Ringo"]
    
    var body: some View {
//        NavigationView{
            TabView(selection: $tabSelection){
                    List {
                        ForEach(dataArray.filter{$0.hasPrefix(searchString) || searchString == ""}, id:\.self) { data in
                            NavigationLink(data, destination: SomeView(text: data, title: data, uiTabarController: nil))
                        }
                    }.onAppear{
                        self.introspectViewController { (UIViewController) in
                            UIViewController.view.setNeedsDisplay()
                            print("reloading...")
                        }
                    }
                
                .tabItem { Text("Tab 1-") }
                .tag("-Tab 1")
                
                NavigationLink("Two", destination: SomeView(text: "Two", title: "Two", uiTabarController: nil))
                .tabItem { Text("Tab 2-") }
                .tag("-Tab 2")
            }
            .navigationBarTitle(tabSelection)
            
//        }
    }
}

struct HideTabBarTestView_Previews: PreviewProvider {
    static var previews: some View {
        HideTabBarTestView()
    }
}

// MARK: - SomeView

struct SomeView: View{
    var text: String
    var title: String
    
    @State var uiTabarController: UITabBarController?
    
    var body: some View {
        
            Text(text)
        
        .toolbar() {
            NavigationToolbar(loadFirst: {},
                              loadPrevious: {},
                              loadRandom: {},
                              loadNext: {},
                              loadLast: {},
                              canDoPrevious: true,
                              canDoNext: true)
        }
        .navigationBarTitle(title, displayMode: .inline)
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
            uiTabarController = UITabBarController
        }.onDisappear{
            uiTabarController?.tabBar.isHidden = false
//            uiTabarController?.view.setNeedsDisplay()
        }
    }
}
