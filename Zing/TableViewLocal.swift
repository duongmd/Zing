//
//  TableViewLocal.swift
//  Zing
//
//  Created by iOS Student on 12/19/16.
//  Copyright © 2016 Duong. All rights reserved.
//

import UIKit

class TableViewLocal: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myTableView: UITableView!
    var listSongs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myTableView.delegate = self
        myTableView.dataSource = self
        
        getData()
    }

    func getData() {
        listSongs.removeAll()
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do {
                //Lay ra het cac folder bai hat
                let folders = try FileManager.default.contentsOfDirectory(atPath: dir)
                for folder in folders {
                    if (folder != ".DS_Store") {        //Khong lay folder DS_Store
                        let info = NSDictionary(contentsOfFile: dir + "/" + folder + "/" + "info.plist")
                        let title = info!["title"] as! String
                        let artistName = info!["artistName"] as! String
                        let thumbnailPath = info!["localThumbnail"] as! String
                        let sourceLocal = dir + "/\(title)/\(title).mp3"
                        let localThumbnail = dir + thumbnailPath
                        
                        let currentSong = Song(title: title, artistName: artistName, localThumbnail: localThumbnail, localSource: sourceLocal)
                        listSongs.append(currentSong)
                    }
                }
                myTableView.reloadData()
            } catch let error as NSError {
                print(error)
            }
        }
    }

    func removeSongAtIndex(_ index: Int){
        if let dir = kDOCUMENT_DIRECTORY_PATH {
            do {
                let path = dir+"/\(listSongs[index].title)"
                try FileManager.default.removeItem(atPath: path)
                listSongs.remove(at: index)
                self.myTableView.reloadData()
            }
            catch let err as NSError {
                print(err)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSongs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocalCell", for: indexPath)
        
        cell.imageView?.image = listSongs[indexPath.row].thumbnail
        cell.textLabel?.text = "\(listSongs[indexPath.row].title) - Ca sỹ: \(listSongs[indexPath.row].artistName)"
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Delete") { action,index in
            self.removeSongAtIndex(indexPath.row)
                self.myTableView.reloadData()
            
        }
        edit.backgroundColor = UIColor(red: 248/255, green: 55/255, blue: 186/255, alpha: 1.0)
        return [edit]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = AudioPlayer.sharedInstance
        audio.pathString = listSongs[indexPath.row].sourceLocal
        audio.titleSong = "\(listSongs[indexPath.row].title) - Ca si: \(listSongs[indexPath.row].artistName)"
        audio.setupAudio()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupObserverAudio"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }



}
