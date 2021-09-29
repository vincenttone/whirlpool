//
//  WhirlpoolHomePageView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/29.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolHomePageView: View {
    
    @ObservedObject
    var controller: WhirlpoolTimingPageController
    
    @ObservedObject
    var store: WhirlpoolRecordStore
    
    @State
    private var showHistory = false
    
    @State
    private var isSaving = false
    
    @State
    private var isSharing = false
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                VStack {
                    WhirlpoolTimingView(record: self.store.current_record)
                    Spacer()
                    WhirlpoolRecordListView(store: self.store)
                    Spacer()
                    HStack {
                        let len = proxy.size.width / 7
                        let btnSize = CGSize(width: len, height: len)
                        Spacer()
                        WhirlpoolSplitButtonView(controller: self.controller, store: self.store, size: btnSize)
                        Spacer()
                        WhirlpoolPlayButtonView(controller: self.controller, store: self.store, size: btnSize)
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
                            if self.store.state == .PAUSING {
                                self.isSharing.toggle()
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .disabled(self.store.state != .PAUSING)
//                        .foregroundColor(self.store.state == .PAUSING ? .blue : .gray)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if self.store.state == .PAUSING {
                                self.isSaving.toggle()
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .disabled(self.store.state != .PAUSING)
//                        .foregroundColor(self.store.state == .PAUSING ? .blue : .gray)
                    }
                }
                .sheet(isPresented: self.$isSaving) {
                    VStack {
                        TextField("标题", text: self.$controller.store.title)
                            .padding()
                            .font(.title)
                        WhirlpoolRecordListView(store: self.store)
                        Button("保存") {
                            self.controller.saveBtnTouched()
                            self.isSaving.toggle()
                        }
                        .font(.title2)
                        .disabled(self.store.title.isEmpty)
                    }
                }
                .sheet(isPresented: self.$isSharing) {
                    WhirlpoolShareSheet(activityItems: [self.store.description])
                }
                .navigationBarTitle(self.store.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct WhirlpoolHomePageView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = WhirlpoolTimingPageController()
        WhirlpoolHomePageView(controller: controller, store: controller.store)
    }
}
