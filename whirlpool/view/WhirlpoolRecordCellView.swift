//
//  WhirlpoolRecordCellView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/10.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolRecordCellView: View {
    @ObservedObject
    var record: WhirlpoolRecord
    
    @State
    var imageName: String = "stopwatch"
    
    @State
    var color: Color = .gray
    
    var body: some View {
        HStack {
            Image(systemName: self.imageName)
                .foregroundColor(color)

            Spacer()
            TextField("添加备注", text: $record.desc)
                .foregroundColor(color)
            
            Spacer()
            Text(TimeHelper.format2ReadableTime(time:  record.time_far))
                .font(.custom("Helvetica Neue", size: 21))
                .foregroundColor(color)
            Divider()
            Text(TimeHelper.format2ReadableTime(time:  record.time))
                .font(.custom("Helvetica Neue", size: 21))
                .foregroundColor(color)
        }
    }
}

struct WhirlpoolRecordCellView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolRecordCellView(record: WhirlpoolRecord(num: 3, uuid: UUID().uuidString))
    }
}
