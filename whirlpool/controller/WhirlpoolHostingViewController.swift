//
//  WhirlpoolHostingViewController.swift
//  WhirlpoolHostingViewController
//
//  Created by Vincent.Tone on 2021/9/10.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

class WhirlpoolHostingViewController: UIHostingController<WhirlpoolMainContainerView> {
    let controller = WhirlpoolTimingPageController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: WhirlpoolMainContainerView(controller: controller))
        controller.tryToRecoverSnapshot()
    }
}


struct WhirlpoolHostingViewController_Previews: PreviewProvider {
    static var previews: some View {
        Text("test text")
    }
}
