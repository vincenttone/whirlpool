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
                        .padding(.horizontal, proxy.size.width / 12)
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
                    .padding()
                }
                .background(NavigationLink("", destination: WhirlpoolHistoryListView(), isActive: self.$showHistory))
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            WhirlpoolHistoryController.shared.reload()
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
                    }
                }
                .sheet(isPresented: self.$isSaving) {
                    VStack {
                        TextField("UNTITLED", text: self.$controller.store.title)
                            .padding()
                            .font(.title)
                            .submitLabel(.done)
                            .onSubmit {
                                self.controller.saveBtnTouched()
                                self.isSaving.toggle()
                            }
                        WhirlpoolRecordListView(store: self.store)
                        Button("SAVE") {
                            self.controller.saveBtnTouched()
                            self.isSaving.toggle()
                        }
                        .font(.title2)
                        .padding()
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
            .onAppear {
                controller.store.current_record.time = TimeInterval(30)
                controller.store.current_record.time_far = TimeInterval(600000)
            }
    }
}
