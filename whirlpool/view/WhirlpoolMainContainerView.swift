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
    
    @State
    private var isSaving = false
    
    @State
    private var title = ""
    
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
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if self.controller.store.state == .PAUSING {
                                self.isSaving.toggle()
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                    ToolbarItem(placement: .navigation) {
                        Text(self.controller.store.title)
                    }
                }
                .sheet(isPresented: self.$isSaving, onDismiss: {

                }, content: {
                    VStack {
                        TextField("标题", text: self.$title)
                            .font(.title)
                        WhirlpoolRecordListView(store: self.controller.store)
                        Button("保存") {
                            self.controller.store.title = self.title
                            self.controller.store.save()
                            self.title = ""
                            self.isSaving.toggle()
                        }
                        .disabled(self.title.isEmpty)
                    }
                })
//                .navigationTitle(self.controller.store.title)
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
