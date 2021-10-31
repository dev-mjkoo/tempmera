//
//  DBManager.swift
//  tempmera
//
//  Created by 구민준 on 2021/10/31.
//

import Foundation
import SQLite3

let DBName = "imageDB"

class DBManager {
  static let shared = DBManager()
  
  var db: OpaquePointer?
  var path = "\(DBName).sqlite"
  
  init() {
    self.db = createDB()
    self.createTable()
  }
  
  func createDB() -> OpaquePointer? {
    var db: OpaquePointer? = nil
    
    do {
      let filePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
      
      if sqlite3_open(filePath.path, &db) == SQLITE_OK {
        print("Successfully create DB path : \(filePath.path)\n")
        
        return db
      }
    }
    catch {
      print("Error in create DB - \(error.localizedDescription)\n")
    }
    
    print("Error in create DB - sqlite3_open\n")
    return nil
  }
  
  func createTable() {
    /* ----------------------------- */
    /* image_name   TEXT           PK*/
    /* image_sjdt   TEXT(8)          */
    /* image_sjtime TEXT(6)          */
    /* image_endt   TEXT(8)          */
    /* image_entime TEXT(6)          */
    /* ----------------------------- */
    let query = "CREATE TABLE IF NOT EXISTS \(DBName)(image_name TEXT PRIMARY KEY, image_sjdt CHAR(8), image_sjtime CHAR(6), image_endt CHAR(8), image_entime CHAR(6));"
    
    print("\(query) \n")
    
    var statement: OpaquePointer? = nil /* 명령을 수행하게 될 DB의 C포인터 위치의 주소를 담는 변수 */
    
    /* -1 : read all */
    if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
      if sqlite3_step(statement) == SQLITE_DONE {
        print("Create Table SuccessFully \(String(describing: db))\n")
      } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Create Table sqlite3_prepare Fail! : \(errorMessage)\n")
      }
      
      /* sqlite3를 수행하면서 생긴 메모리를 제거 */
      sqlite3_finalize(statement)
    }
  }
  
  func deleteTable() {
    let query = "DROP TABLE \(DBName)"
    
    var statement: OpaquePointer? = nil
    
    if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
      if sqlite3_step(statement) == SQLITE_DONE {
        print("Delete Table SuccessFully \(String(describing: db))\n")
      } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Delete Table step fail!: \(errorMessage)\n")
      }
    } else {
      let errorMessage = String(cString: sqlite3_errmsg(db))
      print("Delete Table prepare fail!: \(errorMessage)\n")
    }
    
    /* sqlite3를 수행하면서 생긴 메모리를 제거 */
    sqlite3_finalize(statement)
  }
  
  func insertData(imageData: ImageData) {
    let imageName = imageData.imageName
    let imageSaveDate = imageData.imageSaveDate
    let imageSaveTime = imageData.imageSaveTime
    let imageEndDate = imageData.imageEndDate
    let imageEndTime = imageData.imageEndTime
    
    
    let query = "INSERT INTO \(DBName) (image_name, image_sjdt, image_sjtime, image_endt, image_entime) VALUES (?, ?, ?, ?, ?);"
    
    var statement: OpaquePointer? = nil
    
    print("\(query)\n")
    
    if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
      /* sqlite는 obj-c 언어로 구현되어 있기 때문에 text->NSString으로 변환하고 utf8String으로 인코딩 해아함 */
      sqlite3_bind_text(statement, 1, NSString(string: imageName).utf8String, -1, nil)
      sqlite3_bind_text(statement, 2, NSString(string: imageSaveDate).utf8String, -1, nil)
      sqlite3_bind_text(statement, 3, NSString(string: imageSaveTime).utf8String, -1, nil)
      sqlite3_bind_text(statement, 4, NSString(string: imageEndDate).utf8String, -1, nil)
      sqlite3_bind_text(statement, 5, NSString(string: imageEndTime).utf8String, -1, nil)
      
      
      if sqlite3_step(statement) == SQLITE_DONE {
        print("Insert data Successfully: \(String(describing: db))\n")
      } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Insert Data sqlite3 step fail! : \(errorMessage)\n")
      }
    }
    else {
      let errorMessage = String(cString: sqlite3_errmsg(db))
      print("Insert Data prepare fail!: \(errorMessage)\n")
    }
    
    /* sqlite3를 수행하면서 생긴 메모리를 제거 */
    sqlite3_finalize(statement)
  }
  
  
  func readData() -> [ImageData] {
    let query = "SELECT * FROM \(DBName);"
    var statement: OpaquePointer? = nil
    
    var images: [ImageData] = []
    
    if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
      while sqlite3_step(statement) == SQLITE_ROW {
        let imageName = String(cString: sqlite3_column_text(statement, 0))
        let imageSaveDate =  String(cString: sqlite3_column_text(statement, 1))
        let imageSaveTime =  String(cString: sqlite3_column_text(statement, 2))
        let imageEndDate =  String(cString: sqlite3_column_text(statement, 3))
        let imageEndTime =  String(cString: sqlite3_column_text(statement, 4))
        
        images.append(ImageData(imageName, imageSaveDate, imageSaveTime, imageEndDate, imageEndTime))
        
      }
    } else {
      let errorMessage = String(cString: sqlite3_errmsg(db))
      print("read Data prepare fail! : \(errorMessage)\n")
    }
    
    /* sqlite3를 수행하면서 생긴 메모리를 제거 */
    sqlite3_finalize(statement)
    
    return images
  }
  
  func deleteData(imageName: String) {
    let query = "DELETE FROM \(DBName) WHERE image_name = \(imageName);"
    var statement: OpaquePointer? = nil
    
    if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
      if sqlite3_step(statement) == SQLITE_DONE {
        print("Delete data Successfully: \(String(describing: db))")
      } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Delete Data prepare fail! : \(errorMessage)")
      }
    } else {
      let errorMessage = String(cString: sqlite3_errmsg(db))
      print("Delete Data prepare fail!: \(errorMessage)")
    }
    
    /* sqlite3를 수행하면서 생긴 메모리를 제거 */
    sqlite3_finalize(statement)
  }
  
  func updateData(imageName: String, imageEndDate: String, imageEndTime: String) {
    let query = "UPDATE \(DBName) SET image_endt = \(imageEndDate), imag_entime = \(imageEndTime) WHERE image_name = \(imageName);"
    var statement: OpaquePointer? = nil
    
    if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
      if sqlite3_step(statement) == SQLITE_DONE {
        print("Update data Succeessfully : \(String(describing: db))")
      } else {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Update data prepare fail!: \(errorMessage)")
      }
    } else {
      let errorMesaage = String(cString: sqlite3_errmsg(db))
      print("Update Data prepare fail!: \(errorMesaage)")
    }

    /* sqlite3를 수행하면서 생긴 메모리를 제거 */
    sqlite3_finalize(statement)
  
  }
  
}
