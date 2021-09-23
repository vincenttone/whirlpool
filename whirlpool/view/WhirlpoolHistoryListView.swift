//
//  WhirlpoolHistoryListView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolHistoryListView: View {
    
    @State var page = 1
    
    private let limit = 30
    
    @State
    private var data: [Batch] = WhirlpoolRecordStoreManager.instance.loadHistories(limit: 30, offset: 0)
    
    private var count: Int { WhirlpoolRecordStoreManager.instance.fetchHistoriesCount()
    }
    
    @State
    private var isEndOfPage = false
    
    var body: some View {
//        NavigationView {
            if self.count > 0 {
                //            WhirlpoolRefreshableTableView(data: data, total: data.count) { store in
                //                Text(String(format: "#%d", store.title ?? "暂无标题"))
                //            }
                List(data, id: \.self) { store in
                    NavigationLink(destination: {
                        Text(String(format: "%@", store.title ?? "暂无标题"))
                            .font(.title)
                            .navigationTitle(Text(String(format: "%@", store.title ?? "暂无标题")))
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(String(format: "%@", store.title ?? "暂无标题"))
                                .font(.title2)
                            HStack {
                                Text(store.date!.quickFormat(format: "YYYY-MM-dd HH:mm:ss"))
                                Spacer()
                                Text(String(format: "%d条记录", store.count))
                            }
                            .font(.footnote)
                        }
                    })
                }
                .navigationBarTitle("历史记录")
                .refreshable {
                    if self.count > (self.page - 1) * self.limit {
                        let histories = WhirlpoolRecordStoreManager.instance.loadHistories(limit: self.limit, offset: (self.page  - 1) * self.limit )
                        self.data.append(contentsOf: histories)
                        self.page += 1
                    } else {
                        self.isEndOfPage = true
                    }
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
