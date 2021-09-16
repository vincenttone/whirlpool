//
//  WhirlpoolHistoryListView.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/9.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import SwiftUI

struct WhirlpoolHistoryListView: View {
    
    @State var page = 1
    
    private let contentSize = 20
    
    @State
    private var data = Array(0..<30)
    
    var body: some View {
        
        WhirlpoolRefreshableTableView(data: data, total: data.count) { d in
            VStack {
                Text(String(format: "#%d", d))
            }
        }
        .refreshable {
            data.append(contentsOf: 31..<60)
        }
//        List {
//            ForEach(0..<self.page * contentSize,id : \.self) { num in
//                Text("数据" + "\(num)").frame(height: 100)
//            }
//            Button(action: loadMore) {
//                Text(self.page == 4 ? "已经到底啦" :  "")
//            }
//            .onAppear {
//                DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 100)) {
//                    self.loadMore()
//                }
//            }
//        }
    }
    func loadMore() {
        if self.page < 4 {
            self.page += 1
            print("Load more..." + "\(page)")
        }
    }
}

struct WhirlpoolHistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        WhirlpoolHistoryListView()
    }
}
