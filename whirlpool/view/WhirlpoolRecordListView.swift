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
        List(self.store.records, id: \.self) { record in
            Text(TimeHelper.format2ReadableTime(time:  record.time))
        }
    }
}

struct WhirlpoolRecordListView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolRecordListView(store: WhirlpoolRecordStore())
    }
}
