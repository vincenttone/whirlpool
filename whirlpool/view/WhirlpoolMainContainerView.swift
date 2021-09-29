//
//  WhirlpoolMainContainerView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolMainContainerView: View {
    @ObservedObject
    var controller: WhirlpoolTimingPageController
    
    var body: some View {
        NavigationView {
            WhirlpoolHomePageView(controller: self.controller, store: self.controller.store)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WhirlpoolMainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolMainContainerView(controller: WhirlpoolTimingPageController())
    }
}
