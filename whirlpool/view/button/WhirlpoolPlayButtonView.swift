//
//  WhirlpoolPlayButtonView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/10.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolPlayButtonView: View {
    
    @ObservedObject
    var controller: WhirlpoolTimingPageController
    
    @ObservedObject
    var store: WhirlpoolRecordStore
    
    let size: CGSize
    
    var body: some View {
        Button(action: {
            self.controller.startBtnTouched()
        }, label: {
            Image(systemName: self.store.state == .INIT
                    || self.store.state == .PAUSING
                        ? "play.circle"
                        : "pause.circle")
                .resizable()
                .frame(width: size.width, height: size.height)
                .foregroundColor(self.store.state == .INIT
                                    || self.store.state == .PAUSING
                                    ? .blue
                                    : .green
                )
        })
    }
}

struct WhirlpoolPlayButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = WhirlpoolTimingPageController()
        WhirlpoolPlayButtonView(controller: controller, store: controller.store, size: CGSize(width: 30, height: 30))
    }
}
