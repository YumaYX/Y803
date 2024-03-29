//
//  StatusBarController.swift
//  Y803
//
//  Created by yuma on 2024/03/30.
//

import Cocoa

class StatusBarController {
    private let statusBar: NSStatusBar
    private let mymenu = NSMenu()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var view = NSView()

    var currentLabel: String = ""
    let labelMaker = LabelModel()

    init(){
        // Menubar
        statusBar = NSStatusBar.init()
        prepareMenu()
        
        //Notifications
        prepareReceiveNotification()
    }

    func prepareReceiveNotification(){
        // Notification Center for Music info
        // $ strings /Volumes/Macintoh\ HD/System/Applications/Music.app/Contents/MacOS/Music | grep "com.apple."
        // com.apple.Music.playerInfo または com.apple.iTunes.playerInfo
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.onTrackChange(n:)), name: NSNotification.Name("com.apple.Music.playerInfo"), object: nil)
        
        // Notification Center for Spotify app info
        // $ strings /Applications/Spotify.app/Contents/MacOS/Spotify | grep "com.spotify.client"
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.onTrackChange(n:)), name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"), object: nil)
    }
    
    func prepareMenu(){
        // SF Symbolsで音符のアイコンを表示する
        let symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let musicIcon = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
        musicIcon?.withSymbolConfiguration(symbolConfiguration)
        statusItem.button?.image = musicIcon
        
        statusItem.button?.title = currentLabel
        
        let nowplaying = NSMenuItem(
            title: "Tweet NowPlaying..",
            action: #selector(shareNowPlaying),
            keyEquivalent: "t"
        )
        nowplaying.target = self
        mymenu.addItem(nowplaying)

        mymenu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
        statusItem.menu = mymenu
        
        view.wantsLayer = true
        statusItem.button?.addSubview(view)
    }
    
    @objc func onTrackChange(n: Notification){
        labelMaker.extractMusicInfo(ninformation: n)
        currentLabel = labelMaker.displayLabel
        statusItem.button?.title = currentLabel
    }
    
    @objc func shareNowPlaying(){
        labelMaker.nowplaying()
    }
}
