//
//  WhirlpoolMainContainerView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolMainContainerView: View {
    @ObservedObject
    var controller: WhirlpoolTimingPageController
    
    @State
    private var showHistory = false
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack {
                    WhirlpoolTimingView(record: self.controller.store.current_record)
                    Spacer()
                    WhirlpoolRecordListView(store: self.controller.store)
                    Spacer()
                    HStack {
                        let len = proxy.size.width / 7
                        let btnSize = CGSize(width: len, height: len)
                        Spacer()
                        WhirlpoolSplitButtonView(controller: self.controller, store: self.controller.store, size: btnSize)
                        Spacer()
                        WhirlpoolPlayButtonView(controller: self.controller, store: self.controller.store, size: btnSize)
                        Spacer()
                    }
                    Spacer()
                }
                .background(NavigationLink("", destination: WhirlpoolHistoryListView(), isActive: self.$showHistory))
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.showHistory.toggle()
                        } label: {
                            Image(systemName: "list.triangle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button {
                            // save alert
//                            controller.store.save()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }

                    }
                }
                .navigationTitle(self.controller.store.title)
//                .fullScreenCover(isPresented: self.$showHistory, content: {
//                    WhirlpoolHistoryListView()
//                })
//                .sheet(isPresented: self.$showHistory, content: {
//                    WhirlpoolHistoryListView()
//                })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
//        .navigationBarItems(leading: Button(action: {
//
//        }, label: {
//            Text("Button")
//        }))
        
    }
}

struct WhirlpoolMainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolMainContainerView(controller: WhirlpoolTimingPageController())
    }
}
