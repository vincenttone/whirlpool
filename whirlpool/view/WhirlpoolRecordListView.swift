//
//  WhirlpoolRecordListView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolRecordListView: View {
    @ObservedObject
    var store: WhirlpoolRecordStore
    
    var body: some View {
        List {
            WhirlpoolRecordCellView(record: store.current_record, color: .green)
            ForEach(self.store.records.reversed(), id: \.self) { record in
                WhirlpoolRecordCellView(record: record, imageName: "timer", color: .gray)
            }
        }
    }
}

struct WhirlpoolRecordListView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolRecordListView(store: WhirlpoolRecordStore())
    }
}
