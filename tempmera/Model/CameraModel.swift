//
//  CameraModel.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/25.
//

import SwiftUI
import AVFoundation

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
  
  // Delegate
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if error != nil {
      return
    }
    
    print("pic taken...")
    
    guard let imageData = photo.fileDataRepresentation() else { return }
    self.picData = imageData
    let image = UIImage(data: self.picData)!
    
    /* 앨범에 저장 X */
    //self.savePic(image: image)

    let imageName = "\(ProcessInfo.processInfo.globallyUniqueString).jpeg"
    print("imageName : \(imageName)")
    
    /* 이미지 정보 저장 */
    let myDB = DBManager.shared
    myDB.insertData(imageData: ImageData(imageName))
    
    /* 이미지 저장 */
    ImageFileManager.shared.saveImage(image: image, name: imageName) { status in
      print("이미지를 로컬에 저장 완료")
    }
    
    self.reTake()
  }
  
  
  func savePic(image: UIImage) {
    
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
