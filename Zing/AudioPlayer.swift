//
//  AudioPlayer.swift
//  Zing
//
//  Created by iOS Student on 12/19/16.
//  Copyright © 2016 Duong. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer: NSObject {

    static let sharedInstance = AudioPlayer()
    
    var pathString = ""
    var repeating = false
    var playing = false
    var duration = Float()
    var currentTime = Float()
    var titleSong = ""
    var player = AVPlayer()
    
    func setupAudio(){
        var url = NSURL()
        if let checkURL = NSURL(string: pathString){
            url = checkURL
        } else {
            url = NSURL(fileURLWithPath: pathString)
        }
        let playerItem = AVPlayerItem(url: url as URL)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1.0   //Toc do chay
        player.volume = 0.5
        player.play()
        playing = true
        repeating = true
    }
    
    //Action
    func Repeat(_ repeatSong: Bool){
        if (repeating == true) {
            repeating = true
        } else {
            repeating = false
        }
    }
    func action_PlayPause() {
        if(playing == false){
            player.play()
            playing = true
        }
        else{
            player.pause()
            playing = false
        }
    }
    func sld_Duration(_ value: Float) {
        let timeToSeek = value * duration
        let time = CMTimeMake(Int64(timeToSeek), 1)     //Phai dung CMTime cho doi tuong AVPlayer
        player.seek(to: time)
    }
    
    func sld_Volume(_ value: Float) {
        player.volume = value
    }
}

