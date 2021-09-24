//
//  WhirlpoolHistoryListView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolHistoryListView: View {
    
    @ObservedObject
    private var controller = WhirlpoolHistoryController.shared
    
    var body: some View {
        //        NavigationView {
        if self.controller.total > 0 {
            List {
                ForEach(controller.stores, id: \.self) { store in
                    NavigationLink(destination: {
                        VStack {
                            WhirlpoolTimingView(record: store.current_record!)
                            WhirlpoolRecordListView(store: store, editable: true)
                        }
                        .navigationTitle(Text(String(format: "%@", store.title )))
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(String(format: "%@", store.title))
                                .font(.title2)
                            HStack {
                                Text(store.start_time!.quickFormat(format: "YYYY-MM-dd HH:mm:ss"))
                                Spacer()
                                Text(String(format: "%d条记录", store.count()))
                            }
                            .font(.footnote)
                        }
                    })
                }
                .onDelete { ids in
                    if !ids.isEmpty {
                        let store = self.controller.stores[ids.first!]
                        self.controller.deleteHistory(store)
                    }
                }
            }
            .onAppear(perform: {
                self.controller.reload()
            })
            .navigationBarTitle("历史记录")
            .refreshable {
                print("refresh")
                self.controller.next()
            }
        } else {
            VStack {
                Label("暂无任何记录", systemImage: "ellipsis.rectangle")
            }
        }
        //        }
    }
}

struct WhirlpoolHistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolHistoryListView()
    }
}
