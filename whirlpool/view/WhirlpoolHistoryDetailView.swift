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
    
    @State
    private var isDeleting = false
    
    @Environment(\.isPresented)
    private var isPresented
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                WhirlpoolTimingView(record: store.current_record!)
                    .padding(.horizontal, proxy.size.width / 12)
                Spacer()
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.isDeleting.toggle()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .confirmationDialog("DELETE_CONFIRM", isPresented: self.$isDeleting) {
                Button(role: .destructive) {
                    if self.isPresented {
                        self.dismiss()
                        WhirlpoolHistoryController.shared.deleteHistory(self.store)
                    }
                } label: {
                    Text("DELETE")
                }
            } message: {
                Text(String(format: "%@【%@】?", NSLocalizedString("DELETE", comment: "删除"), self.store.title))
            }
            .sheet(isPresented: self.$isSharing) {
                WhirlpoolShareSheet(activityItems: [self.store.description])
        }
        }

    }
}

struct WhirlpoolHistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolHistoryDetailView(store: WhirlpoolRecordStore())
    }
}
