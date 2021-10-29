//
//  MainView.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/30.
//

import SwiftUI

struct MainView: View {
  
  @State var offset : CGFloat = rect.width
  
  
    var body: some View {
        
      // scrollable Tabs...
      GeometryReader { reader in
        
        // since there are three views
        let frame = reader.frame(in: .global)
        
        ScrollableTabBar(tabs: ["", "", ""], rect: frame, offset: $offset) {
          
          // 나중에 여기에 뷰 3개 넣으면 됨 ex) Home(), Setting(),
          HistoryView()
          CameraView()
          SettingView()
          
        }.ignoresSafeArea()
        
      }.ignoresSafeArea()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

// global usage value
var rect = UIScreen.main.bounds
var edges = UIApplication.shared.windows.first?.safeAreaInsets
