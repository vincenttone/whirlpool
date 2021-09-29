//
//  WhirlpoolHistoryDetailView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/29.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolHistoryDetailView: View {
    @State
    var store: WhirlpoolRecordStore
    
    @State
    private var isSharing = false
    
    var body: some View {
        VStack {
            WhirlpoolTimingView(record: store.current_record!)
            WhirlpoolRecordListView(store: store, editable: true)
        }
        .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
        .navigationBarTitle(Text(String(format: "%@", store.title )))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.isSharing.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: self.$isSharing) {
            WhirlpoolShareSheet(activityItems: [self.store.description])
        }
    }
}

struct WhirlpoolHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolHistoryDetailView(store: WhirlpoolRecordStore())
    }
}
