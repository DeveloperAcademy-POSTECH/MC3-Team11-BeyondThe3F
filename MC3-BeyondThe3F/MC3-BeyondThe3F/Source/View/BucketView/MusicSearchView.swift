//
//  MusicSearchView.swift
//  MC3-BeyondThe3F
//
//  Created by 이연정 on 2023/07/24.
//

import SwiftUI
import MusicKit


struct MusicSearchView: View {
    @StateObject private var musicSearchViewModel = MusicSearchViewModel()
    @Binding var searchTerm: String
    @Binding var isUpdate: Bool
    let musicItemUpdateViewModel = MusicItemUpdateViewModel.shared
    let musicItemDataModel = MusicItemDataModel.shared
    let musicPlayer = MusicPlayer.shared
    var persistentContainer = PersistenceController.shared.container
    
    var body: some View {
        ZStack {
            VStack {
                switch musicSearchViewModel.musicSearchState {
                case .notSearched:
                    ResentlySearchTitle
                    if musicSearchViewModel.resentlySearchList.isEmpty {
                        Spacer()
                            .frame(height: 36)
                        Text("최근 검색어 내역이 없습니다.")
                            .body2(color: .gray400)
                    } else {
                        ResentlySearchList
                    }
                    Spacer()
                case .searching:
                    Spacer()
                        .frame(height: 56)
                    HStack{
                        Spacer()
                        ProgressView("음악 검색 중")
                            .foregroundColor(Color.custom(.gray400))
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.custom(.gray400)))
                        Spacer()
                    }
                case .notFound:
                    Spacer()
                        .frame(height: 56)
                    HStack {
                        Spacer()
                        Text("해당하는 노래를 찾지 못했습니다.")
                            .body2(color: .gray400)
                        Spacer()
                    }
                case .success:
                    MusicSearchResultsList
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.custom(.background))
            .onChange(of: searchTerm, perform: musicSearchViewModel.requestUpdateSearchResults)
        }
        

    }
}

extension MusicSearchView {
    private var ResentlySearchTitle: some View {
        HStack {
            Text("최근 검색 목록")
                .headline(color: .white)
            Spacer()
            Button {
                if !musicSearchViewModel.resentlySearchList.isEmpty {
                    musicSearchViewModel.removeAllMusicHistory()
                }
            } label: {
                Text("모두 지우기")
                    .body2(color: .primary)
                    
            }
        }
    }
    
    private var ResentlySearchList: some View {
        ScrollView {
            LazyVStack {
                ForEach(0 ..< musicSearchViewModel.resentlySearchList.count, id: \.self) { index in
                    HStack {
                        Text(musicSearchViewModel.resentlySearchList[index].songName ?? "")
                            .body1(color: .white)
                            .truncationMode(.tail)
                            .lineLimit(1)
                        Spacer()
                        Text("\(Date.formatToString(searchDate: musicSearchViewModel.resentlySearchList[index].date ?? Date()))")
                            .body2(color: .gray400)
                        Spacer()
                            .frame(width: 24)
                        SFImageComponentView(
                            symbolName: .cancel,
                            color: .white,
                            width: 16,
                            height: 16
                        )
                        .onTapGesture {
                            musicSearchViewModel.removeMusicHistoryById(musicId: musicSearchViewModel.resentlySearchList[index].musicId ?? "")
                        }
                    }
                    .frame(maxWidth: 390)
                    .frame(height: 56)
                    .onTapGesture {
                        let selectedMusicItem = musicSearchViewModel.resentlySearchList[index]
                        
                        Task {
                            let musicInfo = await musicItemDataModel.getInfoByMusicId(selectedMusicItem.musicId ?? "")
                            if let musicItem = musicInfo?.items.first {
                                if let imageURL = musicItem.artwork?.url(width: 500, height: 500) {
                                    musicPlayer.insertMusicAndPlay(
                                        musicItem: MusicItemVO(musicId: selectedMusicItem.musicId ?? "", latitude: 0, longitude: 0, playedCount: 0, songName: selectedMusicItem.songName ?? "", artistName: musicItem.artistName, generatedDate: Date(), savedImage: "\(imageURL)")
                                    )
                                } else {
                                    musicPlayer.insertMusicAndPlay(
                                        musicItem: MusicItemVO(musicId: selectedMusicItem.musicId ?? "", latitude: 0, longitude: 0, playedCount: 0, songName: selectedMusicItem.songName ?? "", artistName: musicItem.artistName, generatedDate: Date())
                                    )
                                }
                            }

                            self.endTextEditing()
                        }
                    }
                }
            }
        }
    }

    private var MusicSearchResultsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(musicSearchViewModel.searchSongs, id: \.self) { item in
                    Button {
                        if let imageURL = item.artwork?.url(width: 500, height: 500) {
                            musicPlayer.insertMusicAndPlay(musicItem: MusicItemVO(musicId: item.id.rawValue, latitude: 0, longitude: 0, playedCount: 0, songName: item.title, artistName: item.artistName, generatedDate: Date(), savedImage: "\(imageURL)"))
                        } else {
                            musicPlayer.insertMusicAndPlay(musicItem: MusicItemVO(musicId: item.id.rawValue, latitude: 0, longitude: 0, playedCount: 0, songName: item.title, artistName: item.artistName, generatedDate: Date()))
                        }
                        
                        musicSearchViewModel.addMusicHistory(musicId: item.id.rawValue, songName: item.title)
                        self.endTextEditing()
                    } label: {
                        HStack {
                            if let existingArtwork = item.artwork {
                                ArtworkImage(existingArtwork, width: 60)
                                    .cornerRadius(8)
                            }
                            Spacer()
                                .frame(width: 16)
                            VStack(alignment: .leading){
                                Text(item.title)
                                    .body1(color: .white)
                                    .padding(.bottom, 4)
                                    .lineLimit(1)
                                Text(item.artistName)
                                    .body2(color: .gray500)
                            }
                            Spacer()
                            Button {
                                Task {
                                    musicItemUpdateViewModel.resetInitialMusicItem()
                                    guard let musicItems = await musicItemDataModel.getInfoByMusicId(item.id.rawValue) else {
                                        return
                                    }
                                    guard let musicItem = musicItems.items.first else {
                                        return
                                    }
                                    musicItemUpdateViewModel.musicItemshared.musicId = musicItem.id.rawValue
                                    musicItemUpdateViewModel.musicItemshared.songName = musicItem.title
                                    musicItemUpdateViewModel.musicItemshared.artistName = musicItem.artistName
                                    if let imageURL = musicItem.artwork?.url(width: 500, height: 500) {
                                        musicItemUpdateViewModel.musicItemshared.savedImage = "\(imageURL)"
                                    } else {
                                        musicItemUpdateViewModel.musicItemshared.savedImage = nil
                                    }
                                }
                                musicItemUpdateViewModel.isEditing = false
                                self.isUpdate = true
                            } label: {
                                SFImageComponentView(symbolName: .plus, color: .white, width: 22, height: 22)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
    }
}


struct MusicSearchPreview: View {
    @State var searchTerm: String = ""
    @State var showAddMusicView = false
    var body: some View {
        VStack {
            TextField("음악을 검색하세요", text: $searchTerm)
            MusicSearchView(
                searchTerm: $searchTerm,
                isUpdate: $showAddMusicView
            )
        }
    }
}


struct MusicSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSearchPreview()
    }
}
