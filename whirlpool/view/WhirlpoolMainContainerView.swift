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
    var store: WhirlpoolRecordStore
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack {
                    WhirlpoolTimingView(record: self.store.current_record)
                    Spacer()
                    WhirlpoolRecordListView(store: self.store)
                    Spacer()
                    HStack {
                        let len = proxy.size.width / 7
                        Spacer()
                        Button(action: {
                            self.store.split()
                        }, label: {
                            Image(systemName: "record.circle")
                                .resizable()
                                .frame(width: len, height: len, alignment: .center)
                        })
                        Spacer()
                        Button(action: {
                            if self.store.isPausing() {
                                self.store.goOn()
                            } else if self.store.isWaiting() {
                                self.store.start()
                            } else if self.store.isTiming() {
                                self.store.pause()
                            }
                        }, label: {
                            Image(systemName: self.store.isPausing() ? "pause.circle" : "play.circle" )
                                .resizable()
                                .frame(width: len, height: len, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        })
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle(store.title)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    WhirlpoolHistoryListView()
                }, label: {
                    Text("Button")
                })
            }
        })
        .navigationBarItems(leading: Button(action: {
            
        }, label: {
            Text("Button")
        }))
        
    }
}

struct WhirlpoolMainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolMainContainerView(store: WhirlpoolRecordStore())
    }
}
