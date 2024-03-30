//
//  LabelModel.swift
//  Y803
//
//  Created by yuma on 2024/03/30.
//

import Cocoa

class LabelModel: NSObject {
    
    var displayLabel:String = ""
    var nowPlaying:String = ""
    //var labelWidth: Int = 0
    
    override init(){
        super.init()
    }
    
    func nowplaying(){
        if (nowPlaying.count <= 0 ){ return }
        let encodedText = nowPlaying.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func makeLabel(song: String, artist: String) -> String {
        var label = song
        if !artist.isEmpty {
            label += " - \(artist)"
        }
        return "♪\(label)"
    }

    private func makeNowPlaying(song: String, artist: String, trackid: String) -> String {
        var postContent = "\(song)"
        if !artist.isEmpty {
            let artistNameForHashtag = artist.replacingOccurrences(of: " ", with: "")
            postContent += " - #\(artistNameForHashtag)"
        }
        postContent += "\n#NowPlaying"
        if trackid.contains("spotify:track:") {
            postContent += " #Spotify"
        }
        return postContent
    }
    
    func extractMusicInfo(ninformation: Notification) {
        let musicinfo = ninformation.userInfo
        if musicinfo?["Player State"] as! String != "Playing" {
            displayLabel = ""
            nowPlaying = ""
            return
        }
        let song = musicinfo!["Name"] as! String
        let artist = musicinfo!["Artist"] as! String
        let trackid = musicinfo?["Track ID"] as? String ?? ""
        self.displayLabel = makeLabel(song: song, artist: artist)
        self.nowPlaying = makeNowPlaying(song:song, artist:artist, trackid:trackid)
    }
}
