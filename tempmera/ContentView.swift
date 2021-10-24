//
//  ContentView.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
  var body: some View {
    CameraView()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
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

// Camera Model...
class CameraModel: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
  @Published var isTaken = false
  @Published var session = AVCaptureSession()
  @Published var alert = false
  
  // since were going to read pic data ...
  @Published var output = AVCapturePhotoOutput()
  
  // preview...
  @Published var preview: AVCaptureVideoPreviewLayer!
  
  // Pic Data...
  @Published var isSaved = false
  
  @Published var picData = Data(count: 0)
  
  func check() {
    // first checking camera has got permission
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      setUp()
      return
    case .notDetermined:
      //retusting for permission
      AVCaptureDevice.requestAccess(for: .video) { (status) in
        if status {
          self.setUp()
        }
      }
    case .denied:
      self.alert.toggle()
      return
      
    default:
      return
    }
  }
  
  func setUp() {
    // setting up camera
    do {
      // setting configs...
      self.session.beginConfiguration()
      
      // change for your own
      let device = self.bestDevice(in: .back)
      
      let input = try AVCaptureDeviceInput(device: device)
      
      // checking and adding to session
      if self.session.canAddInput(input) {
        self.session.addInput(input)
      }
      
      // same for output ...
      if self.session.canAddOutput(self.output){
        self.session.addOutput(self.output)
      }
      
      self.session.commitConfiguration()
    }
    catch {
      print(error.localizedDescription)
    }
  }
  
  // take and retake functions...
  func takePic() {
    DispatchQueue.global(qos: .background).async {
      self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
      DispatchQueue.main.async {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { (timer) in
          self.session.stopRunning()
        }
      }
      
      DispatchQueue.main.async {
        withAnimation{ self.isTaken.toggle() }
      }
    }
  }
  
  func reTake() {
    DispatchQueue.global(qos: .background).async {
      self.session.startRunning()
      
      DispatchQueue.main.async {
        withAnimation{ self.isTaken.toggle() }
        // clearing...
        self.isSaved = false
        self.picData = Data(count: 0)
      }
    }
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    
    
    if error != nil {
      return
    }
    
    print("pic taken...")
    
    guard let imageData = photo.fileDataRepresentation() else { return }
    
    self.picData = imageData
  }
  
  
  func savePic() {
    let image = UIImage(data: self.picData)!
    
    // saving Image...
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    
    self.isSaved = true
    
    print("saved Successfully....")
  }
  
  // 사용가능한 디바이스 타입 ( https://jintaewoo.tistory.com/43 )
  func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
    var deviceTypes: [AVCaptureDevice.DeviceType]!
    
    if #available(iOS 11.1, *) {
      deviceTypes = [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera]
    } else {
      deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera]
    }
    
    let discoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: deviceTypes, mediaType: .video, position: .unspecified
    )
    
    let devices = discoverySession.devices
    guard !devices.isEmpty else { fatalError("Missing capture devices.") }
    
    return devices.first(where: { device in device.position == position })!
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
