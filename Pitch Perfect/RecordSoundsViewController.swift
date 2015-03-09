//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Dimitar Apostolov on 05.03.2015.
//  Copyright (c) 2015 Dimitar Apostolov. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProgress: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!

    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    var recordedAudio: RecordedAudio!
    
    override func viewWillAppear(animated: Bool) {
        toggleUIStateOnRecordingStateChange(isRecordingOn: false)
        super.viewWillAppear(animated)
    }

    @IBAction func recordAudio(sender: UIButton) {
        //Update UI accordingly
        toggleUIStateOnRecordingStateChange(isRecordingOn: true)

        //Get the directory where we can store the recorded audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        //Use the current date/time in order to create a unique file name for the audio file
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        
        let recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        let pathArray = [dirPath, recordingName]
        //Create the
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        //Create the recording session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        //Create an instance of the audio recorded
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        //Assign the current view controller as the recorder's delegate
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        //Prepare for and actully record
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(sender: UIButton) {
        //Update UI
        toggleUIStateOnRecordingStateChange(isRecordingOn: false)
        //Stop recording
        audioRecorder.stop()
        //Clear the recording session
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if flag {
            //Recording completed without errors
            //Now fill in the data to pass to the PlaySoundsViewController
            recordedAudio = RecordedAudio()
            recordedAudio.title = recorder.url.lastPathComponent
            recordedAudio.filePathUrl = recorder.url
            //Segue to the PlaySoundsViewController
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            
            println("Could not record audio")
        }
        //Update the UI
        toggleUIStateOnRecordingStateChange(isRecordingOn: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            //Get the PlaySoundsViewController and pass the recorded audio data to it
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    private func toggleUIStateOnRecordingStateChange(#isRecordingOn: Bool) {
        //Toggle label's visibility (visible when the recording is on, hidden otherwise)
        recordingInProgress.hidden = !isRecordingOn
        //Toggle stop button's visibility (visible when the recording is on, hidden otherwise)
        stopButton.hidden = !isRecordingOn
        //Toggle record button's enabled state (disable when recording is on, enable when recording is stopped)
        recordButton.enabled = !isRecordingOn
    }
}

