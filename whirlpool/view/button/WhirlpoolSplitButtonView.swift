//
//  WhirlpoolSplitButtonView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/10.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolSplitButtonView: View {
    @ObservedObject
    var controller: WhirlpoolTimingPageController
    
    @ObservedObject
    var store: WhirlpoolRecordStore
    
    let size: CGSize
    
    var body: some View {
        Button(action: {
            self.controller.splitBtnTouched()
        }, label: {
            Image(systemName: self.controller.store.state == .PAUSING ? "arrow.uturn.backward.circle" : "record.circle")
                .resizable()
                .frame(width: size.width, height: size.height)
                .foregroundColor(
                    self.controller.store.state == .INIT
                    ? .gray
                    : (self.controller.store.state == .PAUSING
                       ? .red : .blue
                      )
                )
        })
            .disabled(self.store.state == .INIT)
    }
}

struct WhirlpoolSplitButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = WhirlpoolTimingPageController()
        WhirlpoolSplitButtonView(controller: controller, store: controller.store, size: CGSize(width: 30, height: 30))
    }
}
