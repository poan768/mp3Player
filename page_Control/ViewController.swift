//
//  ViewController.swift
//  page_Control
//
//  Created by 陳柏安 on 2023-05-08.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    // 播放狀態(控制播放按鈕)
    enum PlayerState: String{
        case playing = "pause.fill"
        case stop = "play.fill"
    }
    
    // 歌手專輯照片
    @IBOutlet weak var signerImageView: UIImageView!
    
    // 操作區
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var playerBtn: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var timeSlider: UISlider!
    
    // 顯示區
    @IBOutlet weak var signerLable: UILabel!
    @IBOutlet weak var totalSignLable: UILabel!
    @IBOutlet weak var playerCurrentTimeLable: UILabel!
    @IBOutlet weak var playerDurationLable: UILabel!
    
    // 音樂播放器
    var audioPlayer: AVAudioPlayer?
    // 播放狀態
    var isPlaying = false
    // 播放第幾首
    var index = 0
    // 所有歌單
    let totalAlbum = TotalAlbum()
    // 被選擇的歌單
    var theAlbum: [Album]?
    // 歌手
    var signer: String?
    // 計時器
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 預設播放
        theAlbum = totalAlbum.陳勢安
        signer = "陳勢安"
        
        // 左右切換按鈕
        // 設置按鈕在 normal 狀態下的文字
        leftBtn.setTitle("", for: .normal)
        // 將圖片更改
        let imageLeft = UIImage(systemName: "backward.end.fill")
        // 將圖片放進btn
        leftBtn.setImage(imageLeft, for: .normal)
        // 設置按鈕在 normal 狀態下的文字
        rightBtn.setTitle("", for: .normal)
        // 將圖片更改
        let imageRight = UIImage(systemName: "forward.end.fill")
        // 將圖片放進btn
        rightBtn.setImage(imageRight, for: .normal)
        
        // 一開始播放按鈕為停止
        setPlayingImage(icon: .stop)
        
        // UISlider
        // UISlider 滑桿按鈕右邊 尚未填滿的顏色
        timeSlider.maximumTrackTintColor = UIColor.lightGray
        // UISlider 滑桿按鈕左邊 已填滿的顏色
        timeSlider.minimumTrackTintColor = UIColor.white
        // UISlider 的最小值
        timeSlider.minimumValue = 0
        // UISlider 的最大值
        timeSlider.maximumValue = 1
        // UISlider 預設值
        timeSlider.value = 0
        
        // 一開始不顯示時間
        playerCurrentTimeLable.text = ""
        playerDurationLable.text = ""
        
        // signerImageView 導圓角
        signerImageView.layer.cornerRadius = 10
        
        updateUI()
    }
    
    // MARK: Action
    // 此歌手的上一首歌
    @IBAction func previousMusic(_ sender: UIButton) {
        index -= 1
        if index < 0 {
            index = theAlbum!.count - 1
        }
        // 播放音樂
        playerMusic(alblum: theAlbum![index])
        updateUI()
    }
    
    // 此歌手的下一首歌
    @IBAction func nextMusic(_ sender: UIButton) {
        nextMusic()
    }
    
    // 播放按鈕
    @IBAction func player(_ sender: UIButton) {
        if !isPlaying{
            isPlaying = !isPlaying
            // 播放音樂
            playerMusic(alblum: theAlbum![index])
        }else{
            isPlaying = !isPlaying
            audioPlayer?.pause()
            setPlayingImage(icon: .stop)
            print("暫停播放...")
        }
    }
    
    // 切換歌手
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectSinger = sender.titleForSegment(at: sender.selectedSegmentIndex)
        // 將歌名放入播放清單
        let album = totalAlbum.getAlbum(singer: selectSinger!)
        theAlbum = album.album
        // 將歌手放入全域變數(會使用到)
        signer = selectSinger!
        // 從第一首開始
        index = 0
        // 點點等於現在選的歌手index
        pageControl.currentPage = album.index
        // 播放音樂
        playerMusic(alblum: theAlbum![index])
        updateUI()
    }
    
    // pageControl 更改時
    @IBAction func changePage(_ sender: UIPageControl) {
        let album = totalAlbum.getAlbum(index: sender.currentPage)
        theAlbum = album
        // 從第一首開始
        index = 0
        // 點點改動時也更改 segmentedControl
        segmentedControl.selectedSegmentIndex = sender.currentPage
        // 播放音樂
        playerMusic(alblum: theAlbum![index])
        updateUI()
    }
    
    // slider按下時
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        print("按下播放條了")
        timerStop()
    }
    
    // slider放開時
    @IBAction func sliderTouchUP(_ sender: UISlider) {
        print("放開播放條了")
        timerFired()
        setPlaybackProgress(progress: sender.value)
    }
    
    @IBAction func leftSwipe(_ sender: UISwipeGestureRecognizer) {
        index = (index + 1) % theAlbum!.count
    }
    
    // MARK: 自定義方法
    // 更新畫面
    func updateUI() {
        let album = theAlbum![index]
        signerImageView.image = UIImage(named: album.singer)
        signerLable.text = "\(album.singer) \n \(album.singTitle)"
        totalSignLable.text = "\(index + 1) / \(theAlbum!.count)"
    }
    
    // 按下播放時修改播放按鈕
    func setPlayingImage(icon: PlayerState){
        // 設置按鈕在 normal 狀態下的文字
        playerBtn.setTitle("", for: .normal)
        // 將圖片更改
        let imagerun = UIImage(systemName: icon.rawValue)
        // 將圖片放進btn
        playerBtn.setImage(imagerun, for: .normal)
    }
    
    // 播放音樂
    func playerMusic(alblum: Album){
        if let filePath = Bundle.main.path(forResource: alblum.singTitle, ofType: "mp3") {
            let fileURL = URL(fileURLWithPath: filePath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                // 代理播放
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                // 播放
                audioPlayer?.play()
                // 設定播放按鈕
                setPlayingImage(icon: .playing)
                // 顯示播放總時
                playerDurationLable.text = FormatTime.formatTime(getMusicDuration())
                // 顯示計時器啟動
                timerFired()
                print("播放中...", alblum.singTitle)
            } catch {
                print("Error loading audio file: \(error)")
            }
        }
    }
    
    // MARK: 自定義方法 - 抓取音樂播放時間相關
    // 設置音樂播放進度(以0-1為單位)
    func setPlaybackProgress(progress: Float) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let duration = audioPlayer.duration
        let currentTime = TimeInterval(progress) * duration
        audioPlayer.currentTime = currentTime
    }
    
    // 設置音樂播放進度(以秒為單位)
    func setPlaybackProgress(seconds: TimeInterval) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = seconds
    }
    
    // 取得音樂播放進度
    func getPlaybackProgress() -> Float {
        guard let audioPlayer = audioPlayer else {
            return 0.0
        }
        
        return Float(audioPlayer.currentTime / audioPlayer.duration)
    }
    
    // 取得音樂總長度(以秒為單位)
    func getMusicDuration() -> TimeInterval {
        guard let audioPlayer = audioPlayer else {
            return 0.0
        }
        
        return audioPlayer.duration
    }
    
    // 取得當前播放時間（秒）
    func getCurrentTime() -> Double {
        return audioPlayer!.currentTime
    }
    
    // MARK: AVAudioPlayerDelegate 的代理
    // 實作 AVAudioPlayerDelegate 方法，處理播放完成事件等
    @objc func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 音樂播放完成後的處理
        nextMusic()
    }
    
    // 計時器每秒觸發的方法
    func timerFired() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [self] timer in
                // 在這裡放置你想要每秒執行一次的程式碼
                timeSlider.value = getPlaybackProgress()
                // 播放進度時間
                let currentTime = FormatTime.formatTime(getCurrentTime())
                playerCurrentTimeLable.text = currentTime
            }
        }
    }
    
    // MARK: 計時器
    func timerStop() {
        timer?.invalidate()
        timer = nil
    }
    
    // 下一首歌
    func nextMusic() {
        index = (index + 1) % theAlbum!.count
        // 播放音樂
        playerMusic(alblum: theAlbum![index])
        updateUI()
    }
}

