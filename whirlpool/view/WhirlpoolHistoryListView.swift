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
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    var body: some View {
        if self.controller.total > 0 {
            WhirlpoolRefreshableTableView(data: controller.stores, isLastPage: {
                self.controller.isLastPage()
            }) { store in
                    NavigationLink(destination: {
                        WhirlpoolHistoryDetailView(store: store)
                    }, label: {
                        LazyVStack(alignment: .leading) {
                            Text(String(format: "%@", store.title))
                                .padding(.vertical)
                            HStack {
                                Text(String(format: "%d%@", store.count(), NSLocalizedString("RECORDS", comment: "条记录")))
//                                Text("RECORDS")
                                Spacer()
                                Text(store.start_time!.quickFormat(format: "YYYY-MM-dd HH:mm:ss"))
                            }
                            .font(.footnote)
                            .foregroundColor(self.colorScheme == .light ? .green : .gray)
                            .padding(.horizontal)
                        }
                    })
            } onDelete: { ids in
                if !ids.isEmpty && self.controller.stores.count > ids.first! {
                    let store = self.controller.stores[ids.first!]
                    self.controller.deleteHistory(store)
                }
            }
            .navigationTitle("HISTORY")
            .refreshable {
                self.controller.load()
            }
        } else {
            VStack {
                Label("NO_RECORDS", systemImage: "ellipsis.rectangle")
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
