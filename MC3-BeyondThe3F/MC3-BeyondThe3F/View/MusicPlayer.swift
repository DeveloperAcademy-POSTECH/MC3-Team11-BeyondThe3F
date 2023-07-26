//
//  MusicPlayer.swift
//  MC3-BeyondThe3F
//
//  Created by jaesik pyeon on 2023/07/26.
//

import Foundation
import MusicKit
import MediaPlayer

protocol MusicPlayerProtocol{
    func musicPlayer(index:Int)
}

class MusicPlayer{
    static let shared = MusicPlayer()
    
    var delegate:MusicPlayerProtocol?
    
    private init(){
        self.player.prepareToPlay {error in
            if let error = error {
                print(error)
            } else {
                print("prePareToPlay success")
            }
       }
    }
    
    private let player = MPMusicPlayerController.applicationMusicPlayer
    
    var indexOfNowPlayingItem:Int{ player.indexOfNowPlayingItem }
    
    var playlist:[MusicItem] = []{
        didSet{
            player.setQueue(with: oldValue.map{$0.musicId ?? ""})
            self.player.play()
        }
    }
    
    var isLast:Bool{
        self.player.indexOfNowPlayingItem == playlist.count - 1 ? true : false
    }
    
    var currentMusicItem:MusicItem{
        self.playlist[self.player.indexOfNowPlayingItem]
    }
    
    var currentPlayHead:Double{
        get{
            return self.player.currentPlaybackTime
        }
        set{
            self.player.currentPlaybackTime = newValue
        }
    }
    


}
extension MusicPlayer{
    func previousButtonTapped(){
        if self.player.currentPlaybackTime < 5{
            self.player.skipToPreviousItem()
        }else{
            self.player.currentPlaybackTime = 0
        }
    }
    
    func playButtonTapped(){
        if self.player.currentPlaybackRate == 0{
            self.player.play()
        }else{
            self.player.pause()
        }
    }

    func nextButtonTapped(){
        if !isLast{
            self.player.skipToNextItem()
        }
    }
    
//    var currentPlaybackTime: TimeInterval{
//        self.player.currentPlaybackTime
//    }
    
}
