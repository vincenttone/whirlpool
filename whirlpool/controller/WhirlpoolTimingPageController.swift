//
//  WhirlpoolTimingPageController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import Foundation
import UIKit

class WhirlpoolTimingPageController: ObservableObject {
    
    @Published
    var store: WhirlpoolRecordStore
    
    init() {
        self.store = WhirlpoolRecordStoreManager.manager().generateNewCurrentStore()
    }
    
    func startBtnTouched() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if self.store.isWaiting() {
            self.store.start()
            self.resetTimer()
        } else if self.store.isTiming() {
            self.store.pause()
        } else if self.store.isPausing() {
            self.store.goOn()
        }
        self.touchFeedback(feedbackStyle: .heavy)
    }
    
    func splitBtnTouched() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if WhirlpoolRecordStoreManager.manager().currentStore!.isPausing() {
            WhirlpoolRecordStoreManager.manager().tryRemoveSnapshot()
            self.reset()
        } else if WhirlpoolRecordStoreManager.manager().currentStore!.isTiming() {
            self.split()
        } else if WhirlpoolRecordStoreManager.manager().currentStore!.isWaiting() {
            self.doNothing()
        }
        self.touchFeedback(feedbackStyle: .heavy)
    }
    
    private func doNothing() {
    }
    
    private func split() {
        self.store.split()
    }
    
    private func reset() {
        WhirlpoolRecordStoreManager.manager().invalidateTimer()
        self.store = WhirlpoolRecordStoreManager.manager().generateNewCurrentStore()
    }
    
    func tryToRecoverSnapshot() {
        if WhirlpoolRecordStoreManager.manager().recoverSnapshoot() {
            self.store = WhirlpoolRecordStoreManager.manager().currentStore!
            self.resetTimer()
        }
    }
    
    func resetTimer() {
        WhirlpoolRecordStoreManager.manager().resetTimer( {(timer) in
            self.refreshData()
        })
    }
    
    func refreshData() {
        self.store.flushCurrentRecord()
    }
    
    func touchFeedback(feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.impactOccurred()
    }
}
