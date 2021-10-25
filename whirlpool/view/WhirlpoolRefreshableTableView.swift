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
    
    var deleteAction: ((IndexSet) -> Void)?
    
    @Environment(\.refresh)
    private var refresh
    
    @State
    private var isRefreshing = false
    
    init(data: T, isLastPage: @escaping () -> Bool, @ViewBuilder cellBuilder: @escaping (T.Element) -> Cell) {
        self.data = data
        self.isLastPage = isLastPage
        self.cellBuilder = cellBuilder
    }
    
    init(data: T, isLastPage: @escaping () -> Bool, @ViewBuilder cellBuilder: @escaping (T.Element) -> Cell, onDelete: @escaping (IndexSet) -> Void) {
        self.data = data
        self.isLastPage = isLastPage
        self.cellBuilder = cellBuilder
        self.deleteAction = onDelete
    }
    var body: some View {
        GeometryReader { proxy in
            List {
                ForEach(data, id: \.self) { d in
                    self.cellBuilder(d)
                }
                .onDelete(perform: { idxSet in
                    if self.deleteAction != nil {
                        self.deleteAction!(idxSet)
                    }
                })
                HStack {
                    GeometryReader { proxy in
                        Spacer()
                        let offset = proxy.frame(in: .global).minY
                        Label(String(format: NSLocalizedString("TOTAL_NUM_OF_RECORDS", comment: "总记录数"), self.data.count), systemImage: "chevron.up.circle")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .preference(key: ScrollViewBottomOffsetPreferenceKey.self, value: ScrollViewBottomOffset(value: offset))
                        Spacer()
                    }
                }
            }
            .onPreferenceChange(ScrollViewBottomOffsetPreferenceKey.self) { offset in
                DispatchQueue.main.async {
                    if proxy.size.height * 2 > (offset.value * 3 / 2)
                        && self.refresh != nil
                        && !self.isLastPage()
                        && !self.isRefreshing {
                        self.isRefreshing.toggle()
                        Task {
                            await self.refresh!()
                            self.isRefreshing.toggle()
                        }
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
