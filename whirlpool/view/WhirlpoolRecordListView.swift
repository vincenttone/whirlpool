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
    
    @State
    var editable = false
    
    var body: some View {
        List {
            ForEach([store.current_record], id: \.self) { record in
                WhirlpoolRecordCellView(record: record, editable: self.editable, color: .green)
            }
//            .onDelete { _ in
//                if self.editable {
//                    print("delete %@", self.store.current_record.uuid.description)
//                    try? WhirlpoolRecordStore.deleteRecords(uuid: self.store.current_record.uuid)
//                }
//                self.store.remove(at: IndexSet(integer: 0))
//            }
            ForEach(self.store.records.reversed(), id: \.self) { record in
                WhirlpoolRecordCellView(record: record, editable: self.editable, imageName: "timer", color: .gray)
            }
//            .onDelete { idx in
//                var index:IndexSet = []
//                for i in idx {
//                    if self.editable {
//                        let rcd = self.store.records[i]
//                        print("delete %@", rcd.uuid.description)
//                        try? WhirlpoolRecordStore.deleteRecords(uuid: rcd.uuid)
//                    }
//                    index.insert(self.store.records.count - i)
//                }
//                store.remove(at: index)
//            }
        }
    }
}

struct WhirlpoolRecordListView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolRecordListView(store: WhirlpoolRecordStore())
    }
}
