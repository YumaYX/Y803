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
    private var myview = NSView()
    
    // label
    private var currentLabel: String = "♪"
    private var labelSize: Double = 0
    
    // controle music info
    private let labelMaker = LabelModel()
    
    // constant
    private let labelFontSize: CGFloat = 14.0
    private let labelLoopNum: Int = 10
    private let statusBarWidth: Int = 200
    private let statusBarHeight: Int = 24
    
    init(){
        // Menubar
        statusBar = NSStatusBar.init()
        prepareMenu()
        
        // Notifications
        prepareReceiveNotification()
    }
    
    func prepareReceiveNotification(){
        let notification_names: Array<String> = [
            "com.apple.Music.playerInfo",
            "com.spotify.client.PlaybackStateChanged"
        ]
        for notification in notification_names {
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(self.onTrackChange(n:)),
                name: NSNotification.Name(notification),
                object: nil
            )
        }
    }
    
    func prepareMenu(){
        // for share menu
        let nowplaying = NSMenuItem(
            title: "Post NowPlaying..",
            action: #selector(shareNowPlaying),
            keyEquivalent: "t"
        )
        nowplaying.target = self
        mymenu.addItem(nowplaying)
        
        // for quit menu
        mymenu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(AppDelegate.quit(_:)),
                keyEquivalent: "q"
            )
        )
        statusItem.menu = mymenu
        
        myview.wantsLayer = true
        
        if let button = statusItem.button {
            button.wantsLayer = true                      // 追加: レイヤー化
            button.layer?.masksToBounds = true            // はみ出し防止
            button.frame = NSRect(x: 0, y: 0, width: statusBarWidth, height: statusBarHeight)
            button.font = NSFont.systemFont(ofSize: labelFontSize)
            button.title = currentLabel
            button.addSubview(myview)
        }
    }
    
    @objc func shareNowPlaying(){
        labelMaker.nowplaying()
    }
    
    private func start_animation(viewLabelLength: Int) {
        myview.wantsLayer = true
        guard let layer = myview.layer else { return }
    
        // レイヤーの初期位置を調整
        layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        layer.position = CGPoint(x: 0, y: CGFloat(statusBarHeight) / 2.0)
    
        // アニメーションの設定
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.repeatCount = .infinity
        animation.duration = CFTimeInterval(viewLabelLength/20)
        animation.fromValue = 0.0
        animation.toValue = -CGFloat(viewLabelLength)
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
    
        layer.add(animation, forKey: "slideX")
    
        if myview.superview == nil {
            statusItem.button?.addSubview(myview)
        }
    }
    
    private func stop_animation() {
        myview.layer?.removeAllAnimations()
        for subview in myview.subviews { subview.removeFromSuperview() }
        myview.removeFromSuperview()
    }
    
// ...existing code...
private func makeDisplayLabel(startX: Int, labelWidth: Int) -> NSView {
    let container = NSView(frame: NSRect(x: startX, y: -2, width: labelWidth, height: statusBarHeight))
    container.wantsLayer = true

    let textLayer = CATextLayer()
    textLayer.string = currentLabel
    textLayer.font = NSFont.systemFont(ofSize: labelFontSize)
    textLayer.fontSize = labelFontSize

    textLayer.frame = container.bounds
    textLayer.alignmentMode = .left
    textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
    textLayer.isWrapped = false
    textLayer.truncationMode = .none
    textLayer.foregroundColor = NSColor.labelColor.cgColor
    textLayer.foregroundColor = NSColor.white.cgColor

    container.layer?.addSublayer(textLayer)
    return container
}
    
    @objc func onTrackChange(n: Notification){
        stop_animation()
        
        labelMaker.extractMusicInfo(ninformation: n)
        currentLabel = labelMaker.displayLabel
        
        // Pause
        if currentLabel.unicodeScalars.count == 0 {
            statusItem.button?.title = "♪"
            let size: CGFloat = 20
            statusItem.button?.frame = NSRect(x: 0, y: -3, width: size, height: size)
            return
        }
        
        let tempNsLabel = NSTextField(labelWithString: currentLabel)
        tempNsLabel.font = NSFont.systemFont(ofSize: labelFontSize)
        tempNsLabel.sizeToFit()
        labelSize = tempNsLabel.frame.width
        
        // Playing(Short Label)
        if labelSize <= Double(statusBarWidth) * 0.9 {
            statusItem.button?.title = currentLabel
            statusItem.button?.frame = NSRect(x: 0, y: 0, width: statusBarWidth, height: statusBarHeight)
            return
        }
        
        // Playing(Long Label)
        statusItem.button?.title = ""
        statusItem.button?.frame = NSRect(x: 0, y: 0, width: statusBarWidth, height: statusBarHeight)
        
        let oneLabelWidth: Int = Int(labelSize) + Int(Double(statusBarWidth) * 0.5)
        let allLabelWidth = oneLabelWidth * (labelLoopNum + 1)
        
        myview = NSView(frame: NSRect(x: 0, y: 0, width: allLabelWidth, height: statusBarHeight))
        myview.wantsLayer = true
        
        for index in 0...labelLoopNum {
            let startX = index * oneLabelWidth + statusBarWidth
            myview.addSubview(makeDisplayLabel(startX: startX, labelWidth: oneLabelWidth))
        }
        
        start_animation(viewLabelLength: allLabelWidth)
    }
}


