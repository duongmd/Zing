//
//  TableViewOnline.swift
//  Zing
//
//  Created by iOS Student on 11/7/16.
//  Copyright © 2016 Duong. All rights reserved.
//

import UIKit

let kDOCUMENT_DIRECTORY_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first //.first de lay thu muc dau tien la directory trong nhieu thu muc

class TableViewOnline: UIViewController {

    var listSongs = [Song]()
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.dataSource = self
        getData()
    }

    func getData() {
//Lay du lieu tu HTML
        let data = try? Data(contentsOf: URL(string: "http://mp3.zing.vn/bang-xep-hang/bai-hat-Viet-Nam/IWZ9Z08I.html")!)
        
//Dung TFHpple de lay du lieu ben trong
        let doc = TFHpple(htmlData: data)
        if let elements = doc?.search(withXPathQuery: "//h3[@class='title-item']/a") as? [TFHppleElement] {
            for element in elements {
                
//Xu ly trong global queue
                DispatchQueue.global(qos: .default).async(execute: {
                    //Lay ID bai hat
                    let id = self.getID(element.object(forKey: "href") as NSString)
                    //print(id)
                    //link API, co tieng Viet
                    let url = URL(string: "http://api.mp3.zing.vn/api/mobile/song/getsonginfo?keycode=fafd463e2131914934b73310aa34a23f&requestdata={\"id\":\"\(id)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    //Tạo biến stringData lưu nội dung bai hat của url lay duoc tu ID
                    var stringData = ""
                    do {
                        stringData = try String(contentsOf: url!)
                    }
                    catch let error as NSError {
                        print(error)
                    }
                    //Tao bien json dạng dictionary lưu dữ liệu 1 bai hat tu chuoi "stringData" trên
                    
                   // print(stringData)
                    
                    let json = self.convertStringToDictionnary(stringData)
                    if (json != nil) {
                        self.addSongToList(json!)
                    }
                })
                
            }
          
        }
        
    }
    
    func addSongToList(_ json: [String:AnyObject]) {
        let title = json["title"] as! String
        let artistName = json["artist"] as! String
        let thumbnail = json["thumbnail"] as! String
        let source = json["source"]!["128"] as! String
        
        let currentSong = Song(title: title, artistName: artistName, thumbnail: thumbnail, source: source)
        listSongs.append(currentSong)
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }
    
    func convertStringToDictionnary(_ text: String) -> [String: AnyObject]? {
        
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            }
            catch let error as NSError{
                print(error.localizedDescription)
            }
        }
        return nil
    }

//Lay ID nam o phan cuoi path, va xoa duoi .html
    func getID(_ path: NSString) -> NSString {
        let id = (path.lastPathComponent as NSString).deletingPathExtension
        return id as NSString
    }
  
    func downloadSong(_ index: Int){
        let dataSong = try? Data(contentsOf: URL(string: listSongs[index].sourceOnline)!)
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            //Tao folder rieng de luu bai hat
            let pathToWriteSong = "\(dir)/\(listSongs[index].title)"
            do {
                try FileManager.default.createDirectory(atPath: pathToWriteSong, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        
        //ghi bai hat
        writeDataToPath(dataSong! as NSObject, path: "\(pathToWriteSong)/\(listSongs[index].title).mp3")
        
        //Ghi thong tin bai hat
        writeInfoSong(listSongs[index], path: pathToWriteSong)
    }
    }
    func writeDataToPath(_ data: NSObject, path: String){
        if let dataToWrite = data as? Data {
            try? dataToWrite.write(to: URL(fileURLWithPath: path), options: [.atomic])
        }
        else if let dataInfo = data as? NSDictionary {
            dataInfo.write(toFile: path, atomically: true)
        }
    }
    
    func writeInfoSong(_ song: Song, path: String) {
        let dicData = NSMutableDictionary()
        dicData.setValue(song.title, forKey: "title")
        dicData.setValue(song.artistName, forKey: "artistName")
        dicData.setValue("/\(song.title)/thumbnail.png", forKey: "localThumbnail")
        dicData.setValue(song.sourceOnline, forKey: "sourceOnline")
        
        writeDataToPath(dicData, path: "\(path)/info.plist")
        
        let dataThumbnail = NSData(data: UIImagePNGRepresentation(song.thumbnail)!) as Data
        writeDataToPath(dataThumbnail as NSObject, path: "\(path)/thumbnail.png")
        
        
    }
    
}

//Đổ dữ liệu lên TableView
extension TableViewOnline :  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OnlineCell", for: indexPath)
        
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = "\(listSongs[indexPath.row].title) - Ca sỹ: \(listSongs[indexPath.row].artistName)"
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Download") { action,index in
            DispatchQueue.global(qos: .default).async(execute: { 
                self.downloadSong(indexPath.row)
            })
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = AudioPlayer.sharedInstance
        audio.pathString = listSongs[indexPath.row].sourceOnline
        audio.titleSong = "\(listSongs[indexPath.row].title) - Ca si: \(listSongs[indexPath.row].artistName)"
        audio.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"), object: nil)
    }


}

