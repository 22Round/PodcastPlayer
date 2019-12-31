//
//  PlayerDetailsView.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/11/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    var episode:Episode! {
        
        didSet {
            
            miniTitleLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            
            setupAudioSession()
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl!.toSecureHTTPS()) else { return }
            
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                
                guard let image = image else { return }
                
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artWork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                    return image
                })
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artWork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    //MARK: - Awake From Nib
    
    var panGesture:UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
        setupGestures()
        observePlayerCurrentTime()
        observeBoundaryTime()
        setupInterruptionObserver()
    }
    
    static func initFromNib() ->PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }

    deinit {
        print("deinit completed")
    }
    
    //MARK: - Functions & closures
    
    
    //MARK: Control Center Player Setup
    
    fileprivate func setupInterruptionObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification:Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }else {
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                self.player.play()
                self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    fileprivate func setupElapsedTime(playbackRate:Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func setupLockscreenDuration(){
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(value: 1,timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImageView()
            self?.setupLockscreenDuration()
        }
    }

    //bug not using
    fileprivate func setupLockscreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        guard let currentItem = player.currentItem else { return }
        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupNowPlayingInfo() {
        
        var nowPlayingInfo = [String:Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupRemoteControl() {
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
       
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
        
    }
    
    var playListEpisodes = [Episode]()
    
    @objc func handlePrevTrack() -> MPRemoteCommandHandlerStatus{
        if playListEpisodes.count == 0 {
            return .commandFailed
        }
        
        let currentEpisodeIndex = playListEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else { return .commandFailed}
        let nextEpisode:Episode
        
        if index == 0 {
            nextEpisode = playListEpisodes[playListEpisodes.count - 1]
        }else {
            nextEpisode = playListEpisodes[index - 1]
        }
        
        self.episode = nextEpisode
        return .success
    }
    
    @objc func handleNextTrack() -> MPRemoteCommandHandlerStatus{
        
        if playListEpisodes.count == 0 {
            return .commandFailed
        }
        
        let currentEpisodeIndex = playListEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else { return .commandFailed }
        let nextEpisode:Episode
        
        if index == playListEpisodes.count - 1{
            nextEpisode = playListEpisodes[0]
        }else {
            nextEpisode = playListEpisodes[index + 1]
        }
        
        self.episode = nextEpisode
        return .success
        
    }
    
    fileprivate func setupAudioSession () {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
        }catch let sessionEr {
            print("Faild to activate Session: ", sessionEr)
        }
    }
    
    
    //MARK: - Player & Layout
    fileprivate func seekToCurrentTime(delta:Int64){
        let seekSeconds = CMTimeMake(value: delta, timescale: Int32(NSEC_PER_SEC))
        let seekTime = CMTimeAdd(player.currentTime(), seekSeconds)
        player.seek(to: seekTime)
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            
            if let durationTime = self?.player.currentItem?.duration, self?.player.currentItem?.status == .readyToPlay {
                
                self?.currentTimeLabel.text = time.toDisplayString()
                self?.durationLabel.text = durationTime.toDisplayString()
                
                //self?.setupLockscreenCurrentTime()
                self?.updateCurrentSliderTime()
            }
        }
    }
    
    fileprivate func updateCurrentSliderTime(){
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
    }
    
    fileprivate func enlargeEpisodeImageView(){
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate let shrinkScale:CGFloat = 0.7
    fileprivate lazy var shrinkTransform = CGAffineTransform(scaleX: self.shrinkScale, y: self.shrinkScale)
    
    fileprivate func shrinkEpisodeImageView(){
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrinkTransform
        })
    }
    
    fileprivate func playEpisode(){

        var trackUrl:URL
        
        if let fileUrl = self.episode.fileUrl {
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            guard let fileURL = URL(string: fileUrl) else { return }
            let fileName = fileURL.lastPathComponent
            trueLocation.appendPathComponent(fileName)
            trackUrl = trueLocation
            
        } else {
            
             guard let url = URL(string: episode.streamUrl) else { return }
            trackUrl = url
        }
        
        let playerItem = AVPlayerItem(url: trackUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
    }
    
    @objc func handlePlayPause(){
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            setupElapsedTime(playbackRate: 1)
        }else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            setupElapsedTime(playbackRate: 0)
        }
    }
    
    let player:AVPlayer = {
       
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
        
    }()
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var miniFastForwardButton: UIButton!
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrinkTransform
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
        
        let percentage = currentTimeSlider.value
        
        guard let duration  = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
    }
    
    @IBAction func handleMiniFastForward(_ sender: UIButton) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleFastForward(_ sender: UIButton) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleRewind(_ sender: UIButton) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleValumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func handleDismiss(_ sender: UIButton) {
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
