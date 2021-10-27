//
//  ContentView.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/24.
//

import SwiftUI
import AVFoundation



struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}

struct CameraView: View {
  
  @StateObject var camera = CameraModel()
  
  var body: some View {
    ZStack {
      CameraPerview(camera: camera).ignoresSafeArea(.all, edges: .all)
      
      VStack {
        
        if camera.isTaken {
          HStack {
            Spacer()
            
            // 카메라 전환 기능 넣을거임
            Button(action: camera.reTake, label: {
              Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .clipShape(Circle())
            }).padding(.trailing, 10)
          }
        }
        
        Spacer()
        
        HStack {
          // if taken showing save and again take button...
          
          if camera.isTaken {
            Button(action: {if !camera.isSaved{ camera.savePic()}}, label: {
              Text(camera.isSaved ? "Saved" : "Save")
                .foregroundColor(.black)
                .fontWeight(.semibold)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white)
                .clipShape(Capsule())
            }).padding(.leading)
            
            Spacer()
          }
          else {
            Button(action: camera.takePic, label: {
              ZStack {
                Circle()
                  .fill(Color.white)
                  .frame(width: 65, height: 65)
                
                Circle()
                  .stroke(Color.white, lineWidth: 2)
                  .frame(width: 75, height: 75)
              }
            })
          }
        }
        .frame(height: 75)
        
      }
    }
    .onAppear {
      camera.check()
    }
  }
}


// setting view for preview...
struct CameraPerview: UIViewRepresentable {
  @ObservedObject var camera: CameraModel
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: UIScreen.main.bounds)
    
    camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
    camera.preview.frame = view.frame
    
    // Your own properties...
    camera.preview.videoGravity = .resizeAspectFill
    view.layer.addSublayer(camera.preview)
    
    // starting session
    camera.session.startRunning()
    
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    
  }
}
