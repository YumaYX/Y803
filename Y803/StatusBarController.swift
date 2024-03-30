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
    private let statusItem = NSStatusBar.system.statusItem(withLength: 200)
    private var myview = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 20))

    // label
    private var currentLabel: String = "♪"
    private var labelSize:Int = 0

    // controle music info
    private let labelMaker = LabelModel()
    
    // constant
    private let labelFontSize: CGFloat = 14.0
    private let labelLoopNum: Int = 10
    
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
        // com.apple.Music.playerInfo or com.apple.iTunes.playerInfo
        // and
        // Notification Center for Spotify app info
        // $ strings /Applications/Spotify.app/Contents/MacOS/Spotify | grep "com.spotify.client"
        let notification_names: Array<String> = ["com.apple.Music.playerInfo", "com.spotify.client.PlaybackStateChanged"]
        for notification in notification_names {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.onTrackChange(n:)), name: NSNotification.Name(notification), object: nil)
        }
    }
    
    func prepareMenu(){
        // for share menu
        let nowplaying = NSMenuItem(title: "Post NowPlaying..", action: #selector(shareNowPlaying), keyEquivalent: "t")
        nowplaying.target = self
        mymenu.addItem(nowplaying)

        // for quit menu
        mymenu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
        statusItem.menu = mymenu

        myview.wantsLayer = true
        myview.layer?.backgroundColor = CGColor.clear

        statusItem.button?.font = NSFont.systemFont(ofSize: CGFloat(labelFontSize))
        statusItem.button?.title = currentLabel
        statusItem.button?.addSubview(myview)
    }
        
    @objc func shareNowPlaying(){
        labelMaker.nowplaying()
    }

    private func start_animation(viewlabellength: Int) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.repeatCount = .infinity
        animation.duration = CFTimeInterval((viewlabellength/20))
        animation.fromValue = myview.layer?.position
        animation.toValue = NSValue(point: NSPoint(x: -(viewlabellength + 200), y: 0))

        myview.wantsLayer = true
        myview.layer?.add(animation, forKey: "position")

        statusItem.button?.addSubview(myview)
    }
    
    private func stop_animation() {
        myview.layer?.removeAllAnimations()
        for subview in myview.subviews { subview.removeFromSuperview() }
        for subview in statusItem.button!.subviews { subview.removeFromSuperview() }
    }
    
    private func makeDisplayLabel(startX: Int, labelWidth: Int) -> NSView {
        let label = NSTextField(frame: NSRect(x: startX, y: -3, width: labelWidth, height: 20))
        label.stringValue = currentLabel
        label.font = NSFont.systemFont(ofSize: CGFloat(labelFontSize))
        label.isEditable = false
        label.isSelectable = false
        label.isBezeled = false
        label.drawsBackground = false
        return label
    }

    @objc func onTrackChange(n: Notification){
        stop_animation()

        labelMaker.extractMusicInfo(ninformation: n)
        currentLabel = labelMaker.displayLabel

        // Pause
        if currentLabel.unicodeScalars.count == 0 {
            statusItem.button?.title = "♪"
            return
        }

        labelSize = currentLabel.count * 12 // 12がアルファベット、日本語の幅に適切

        // Playing(Short Label)
        if labelSize <= 195 {
            statusItem.button?.title = currentLabel
            return
        }

        // Playing(Long Label)
        statusItem.button?.title = ""
        let allLabelWidth = labelSize * labelLoopNum
        myview = NSView(frame: NSRect(x: 0, y: 0, width: allLabelWidth, height: 20))
        for index in 0...labelLoopNum {
            myview.addSubview(makeDisplayLabel(startX: (index * labelSize) + 200, labelWidth: labelSize + 200))
        }
        start_animation(viewlabellength: allLabelWidth)
    }
}
