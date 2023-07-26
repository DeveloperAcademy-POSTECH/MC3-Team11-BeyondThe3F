//
//  BucketView.swift
//  MC3-BeyondThe3F
//
//  Created by Seungui Moon on 2023/07/18.
//

import SwiftUI

struct BucketView: View {
    let musicPlayer = MusicPlayer.shared
    var body: some View {
        VStack(spacing:40){
            Text("Hello, World!")
            Button {
                musicPlayer.playlist = MainDataModel.shared.getData[0].musicList
            } label: {
                Text("playList")
            }

            Button {
                musicPlayer.previousButtonTapped()
            } label: {
                Text("previous Button Tapped")
            }
            Button {
                musicPlayer.playButtonTapped()
            } label: {
                Text("play Button Tapped")
            }
            Button {
                musicPlayer.nextButtonTapped()
            } label: {
                Text("next Button Tapped")
            }
            Button {
                print(musicPlayer.currentMusicItem)
            } label: {
                Text("nowPlayingItem")
            }
        }

    }
}

struct BucketView_Previews: PreviewProvider {
    static var previews: some View {
        BucketView()
    }
}
