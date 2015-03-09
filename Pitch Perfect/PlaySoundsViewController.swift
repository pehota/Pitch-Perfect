//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Dimitar Apostolov on 06.03.2015.
//  Copyright (c) 2015 Dimitar Apostolov. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    @IBOutlet weak var stopPlaying: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Create an instance of the audioplayer using the receivedAudio data
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        if audioPlayer != nil {
            //enable
            audioPlayer.enableRate = true
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        
            audioEngine = AVAudioEngine()
            audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        } else {
            println("Could not create audio player")
        }
    }
    
    @IBAction func stopAudio() {
        
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer.currentTime = 0.0
            audioEngine.stop()
            audioEngine.reset()
            stopPlaying.hidden = true
        }
    }
    
    
    @IBAction func playSlowAudio() {
        playAudioWithRate(0.5)
    }
    
    @IBAction func playFastAudio() {
        playAudioWithRate(1.5)
    }
    
    func playAudioWithRate(rate: Float) {
        if audioPlayer != nil {
            stopAudio()
            audioPlayer.rate = rate
            audioPlayer.play()
            stopPlaying.hidden = false
        }
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        //Create the pitch effect using the provided pitch
        var changePitchEffect = AVAudioUnitTimePitch()
        //Make sure the pitch is in the correct range
        changePitchEffect.pitch = max(min(pitch, 2400), -2400)
        
        playAudioWithEffect([changePitchEffect])
    }
    
    func playAudioWithEffect(effects: [AVAudioNode]) {
        stopAudio()
        
        if audioEngine != nil {
            //Create an audi player node
            let audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attachNode(audioPlayerNode)
            
            var latestEffect: AVAudioNode = audioPlayerNode
            
            //Loop through the provided audio effects and attache them to the audio engine
            for effect in effects {
                audioEngine.attachNode(effect)
                //connect the latest effect to the current effect
                audioEngine.connect(latestEffect, to: effect, format: nil)
                //set the latestEffect to the current effect in order to use it in the next loop
                latestEffect = effect
            }
            //Connect the latest effect to audio engine's output node
            audioEngine.connect(latestEffect, to: audioEngine.outputNode, format: nil)
            
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            
            audioEngine.startAndReturnError(nil)
            
            audioPlayerNode.play()
            
            stopPlaying.hidden = false
        }
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio() {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playAudioWithReverb() {
        let reverb = AVAudioUnitReverb()
        reverb.wetDryMix = 50
        playAudioWithEffect([reverb])
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        self.stopAudio()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stopPlaying.hidden = true
    }

}
