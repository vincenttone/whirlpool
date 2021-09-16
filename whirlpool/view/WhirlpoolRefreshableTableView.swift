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
    var total: Int
    var cellBuilder: (T.Element) -> Cell
    
    @Environment(\.refresh)
    private var refresh
    
    @State
    private var isRefreshing = false
    
    init(data: T, total: Int, @ViewBuilder cellBuilder: @escaping (T.Element) -> Cell) {
        self.data = data
        self.total = total
        self.cellBuilder = cellBuilder
    }
    var body: some View {
        List {
            topView
            ForEach(data, id: \.self) { d in
                self.cellBuilder(d)
            }
            bottomView
                .onAppear {
                    if self.refresh != nil && !self.isRefreshing{
                        self.isRefreshing.toggle()
                        Task {
                            print("Refresh")
                            await self.refresh!()
                        }
                        self.isRefreshing.toggle()
                    }
                }
        }
//        .onPreferenceChange(ScrollViewBottomOffsetPreferenceKey.self) { offset in
//            if self.refresh != nil && !self.isRefreshing{
//                self.isRefreshing.toggle()
//                Task {
//                    print("Refresh")
//                    await self.refresh!()
//                }
//                self.isRefreshing.toggle()
//            }
//        }
    }
    
    var topView: some View {
        Color.clear
    }
    
    var bottomView: some View {
        Color.clear
//        GeometryReader { proxy in
//            let offset = proxy.frame(in: .global).minY
//            Color.clear.preference(key: ScrollViewBottomOffsetPreferenceKey.self, value: ScrollViewBottomOffset(offset: offset))
//        }
    }
}

//struct ScrollViewBottomOffset: Equatable {
//    var offset: CGFloat
//}
//
//struct ScrollViewBottomOffsetPreferenceKey: PreferenceKey {
//    static var defaultValue = ScrollViewBottomOffset(offset: 0)
//
//    static func reduce(value: inout ScrollViewBottomOffset, nextValue: () -> ScrollViewBottomOffset) {
//        value = nextValue()
//    }
//}

struct WhirlpoolRefreshableTableView_Previews: PreviewProvider {
    static var previews: some View {
        let data = 0..<30
        WhirlpoolRefreshableTableView(data: data, total: data.count) { d in
            VStack {
                Text(String(format: "#%d", d))
            }
        }
    }
}
