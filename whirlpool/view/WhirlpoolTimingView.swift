//
//  WhirlpoolTimingView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolTimingView: View {
    @ObservedObject
    var record: WhirlpoolRecord
    
    var body: some View {
        Text(TimeHelper.format2ReadableTime(time: record.time_far))
            .font(.custom("helvetica neue", size: 720))
            .fontWeight(.thin)
            .scaledToFit()
            .minimumScaleFactor(0.1)
            .lineLimit(1)
    }
}

struct WhirlpoolTimingView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolTimingView(record: WhirlpoolRecord(num: 0, time: TimeInterval(30), time_far: TimeInterval(6000000)))
    }
}
