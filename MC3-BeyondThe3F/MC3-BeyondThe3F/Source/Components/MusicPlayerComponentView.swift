//
//  MusicPlayerComponentView.swift
//  MC3-BeyondThe3F
//
//  Created by 한영균 on 2023/07/20.
//

import SwiftUI
import MusicKit

struct MusicPlayerComponentView: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var musicSubscriptionManager = MusicSubscriptionManager.shared
    @State private var showMusicPlayListView = false
    @State private var currentPlayingMusicItem: MusicItemVO? = nil
    @State private var isShowingOffer = false
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: musicPlayer.currentMusicItem?.savedImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } placeholder: {
                Image("musicPlayImageEmpty")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            Spacer()
                .frame(width: 16)
            
            VStack(alignment: .leading) {
                if let currentMusicItem = musicPlayer.currentMusicItem {
                    Text("\(currentMusicItem.songName)")
                        .body1(color: .white)
                        .truncationMode(.tail)
                        .lineLimit(1)
                    Spacer()
                        .frame(height: 6)
                    Text("\(currentMusicItem.artistName)")
                        .body2(color: .gray500)
                        .truncationMode(.tail)
                        .lineLimit(1)
                } else {
                    Text("재생 중이 아님")
                        .body1(color: .white)
                        .truncationMode(.tail)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(width: 16)
            
            HStack(spacing: 24) {
                Button {
                    if let _ = musicSubscriptionManager.subscriptionState?.canBecomeSubscriber {
                        showSubscriptionOffer()
                    } else {
                        musicPlayer.playButtonTapped()
                    }
                } label: {
                    switch musicPlayer.playState {
                    case .paused, .stopped:
                        SFImageComponentView(symbolName: .play, color: .white, width: 20)
                    default:
                        SFImageComponentView(symbolName: .pause, color: .white, width: 20)
                    }
                }
                Button("Show Subscription Offers", action: showSubscriptionOffer)
                    .disabled(!(musicSubscriptionManager.subscriptionState?.canBecomeSubscriber ?? false))
                
                Button {
                    if let _ = musicSubscriptionManager.subscriptionState?.canBecomeSubscriber {
                        showSubscriptionOffer()
                    } else {
                        musicPlayer.nextButtonTapped()
                    }
                } label: {
                    SFImageComponentView(symbolName: .forward, color: .white, width: 32)
                }
                .disabled(musicPlayer.isLast)
                
                Button {
                    showSubscriptionOffer()
                } label: {
                    SFImageComponentView(symbolName: .list, color: .white)
                }
            }
        }
        .padding(.horizontal, 20)
        .foregroundColor(.white)
        .frame(width: 390, height: 88)
        .background(Color.custom(.secondaryDark))
        .sheet(isPresented: $showMusicPlayListView) {
            MusicPlayView(showCurrentPlayList: true)
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            self.currentPlayingMusicItem = musicPlayer.currentMusicItem
            
        }
        .onChange(of: musicPlayer.musicInPlaying) { newValue in
            self.currentPlayingMusicItem = newValue
        }
        .musicSubscriptionOffer(isPresented: $isShowingOffer, options: musicSubscriptionManager.offerOptions)
    }
    
    private func showSubscriptionOffer(){
        // TODO: musicSubscriptionManager.currentID에 추천하는 음악 MusicItemID를 넣어주어야 한다.
        if let currentMusic = musicPlayer.currentMusicItem {
            musicSubscriptionManager.currentId = MusicItemID(currentMusic.musicId)
        } else {
            isShowingOffer = true
        }

    }
}

