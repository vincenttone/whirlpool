//
//  WhirlpoolRefreshableTableView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/14.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolRefreshableTableView<T: RandomAccessCollection, Cell: View>: View where T.Element: Hashable {
    var data: T
    
    var isLastPage: () -> Bool
    
    var cellBuilder: (T.Element) -> Cell
    
    @Environment(\.refresh)
    private var refresh
    
    @State
    private var isRefreshing = false
    
    
    init(data: T, isLastPage: @escaping () -> Bool, @ViewBuilder cellBuilder: @escaping (T.Element) -> Cell) {
        self.data = data
        self.isLastPage = isLastPage
        self.cellBuilder = cellBuilder
    }
    var body: some View {
        GeometryReader { proxy in
            List {
                ForEach(data, id: \.self) { d in
                    if d == data.last {
                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .global).minY
                            self.cellBuilder(d)
                                .preference(key: ScrollViewBottomOffsetPreferenceKey.self, value: ScrollViewBottomOffset(value: offset))
                        }
                    } else {
                        self.cellBuilder(d)
                    }
                }
                .onDelete(perform: { idxSet in
                    if self.deleteAction != nil {
                        self.deleteAction!(idxSet)
                    }
                })
                
            }
            .onPreferenceChange(ScrollViewBottomOffsetPreferenceKey.self) { offset in
                if proxy.size.height > (offset.value * 2 / 3)
                    && self.refresh != nil
                    && !self.isLastPage()
                    && !self.isRefreshing {
                    self.isRefreshing.toggle()
                    Task {
                        print("Refresh", self.isLastPage())
                        await self.refresh!()
                        self.isRefreshing.toggle()
                    }
                }
            }
        }
    }

//
//    var topView: some View {
//        Color.clear
//    }
//
//    var bottomView: some View {
//        GeometryReader { proxy in
//            let offset = proxy.frame(in: .global).minY
//            Color.clear.preference(key: ScrollViewBottomOffsetPreferenceKey.self, value: ScrollViewBottomOffset(value: offset))
//        }
//    }
    
    @State
    var deleteAction: ((IndexSet) -> Void)?
}

extension WhirlpoolRefreshableTableView {
    func onDelete(action: @escaping (IndexSet) -> Void) -> WhirlpoolRefreshableTableView {
        self.deleteAction = action
        return self
    }
}

struct ScrollViewBottomOffset: Equatable {
    var value: CGFloat
}

struct ScrollViewBottomOffsetPreferenceKey: PreferenceKey {
    static var defaultValue = ScrollViewBottomOffset(value: 0)

    static func reduce(value: inout ScrollViewBottomOffset, nextValue: () -> ScrollViewBottomOffset) {
        value = nextValue()
    }
}

struct WhirlpoolRefreshableTableView_Previews: PreviewProvider {
    static var previews: some View {
        let data = 0..<30
        WhirlpoolRefreshableTableView(data: data, isLastPage: {
            false
        }) { d in
            VStack {
                Text(String(format: "#%d", d))
            }
            .padding()
        }
    }
}
