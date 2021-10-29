//
//  ScrollableTabBar.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/30.
//

import SwiftUI


// Were going to create our own View
// By Using View Builders

struct ScrollableTabBar<Content: View>: UIViewRepresentable {
  
  /* Variable */
  
  // to store out SwiftUI View
  var content: Content
  
  // Getting Rect To Calcualte Width And Height Of ScrollView...
  var rect: CGRect
  
  // ContentOffSet...
  @Binding var offset: CGFloat
  
  // Tabs...
  var tabs: [Any]
  
  // ScrollView...
  // For Paging aka Scrollable Tabs...
  let scrollView = UIScrollView()
  
  
  init(tabs: [Any], rect: CGRect, offset: Binding<CGFloat>, @ViewBuilder content: () -> Content ) {
    self.content = content()
    self._offset = offset
    self.rect = rect
    self.tabs = tabs
  }
  
  func makeCoordinator() -> Coordinator {
    return ScrollableTabBar.Coordinator(parent: self)
  }
  
  func makeUIView(context: Context) -> UIScrollView {
    
    setUpScrollView()
    
    // setting Content Size ...
    scrollView.contentSize = CGSize(width: rect.width * CGFloat(tabs.count), height: rect.height)
    scrollView.contentOffset.x = offset
    scrollView.addSubview(extractView())
    scrollView.delegate = context.coordinator
    
    return scrollView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    // update View...
    if uiView.contentOffset.x != offset {
      
      // animating
      // the animation glitch is because it's updating on two times
    
      // removing delegate while animating
      uiView.delegate = nil
      
      UIView.animate(withDuration: 0.4) {
        uiView.contentOffset.x = offset
      } completion: { status in
        if status { uiView.delegate = context.coordinator }
      }
    }
  }
  
  // setting up scrollView...
  func setUpScrollView() {
    scrollView.isPagingEnabled = true
    scrollView.bounces = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
  }
  
  // Extracting SwiftUi View...
  func extractView() -> UIView {
    
    // since it depents upon tab size
    // so we getting tabs also ...
    let controller = UIHostingController(rootView: HStack(spacing: 0) { content }.ignoresSafeArea() )
    controller.view.frame = CGRect(x: 0, y: 0, width: rect.width * CGFloat(tabs.count), height: rect.height)
    
    return controller.view!
  }
  
  // Delegate Function to get offset...
  class Coordinator: NSObject, UIScrollViewDelegate {
    var parent: ScrollableTabBar
    
    init(parent: ScrollableTabBar) {
      self.parent = parent
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      parent.offset = scrollView.contentOffset.x
    }
  }
}

struct ScrollableTabBar_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
