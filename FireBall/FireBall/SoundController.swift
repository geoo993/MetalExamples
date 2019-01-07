//
//  SoundController.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 03/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import AVFoundation

final class SoundController {

    static let shared = SoundController()
    var backgroundMusicPlayer: AVAudioPlayer?
    var popEffect: AVAudioPlayer?
    init() { }

    func preloadSoundEffect(_ filename: String) -> AVAudioPlayer? {
        if let url = Bundle.main.url(forResource: filename,withExtension: nil) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                return player
            } catch {
                print("file \(filename) not found")
            }
        }

        return nil
    }

    // Here you preload the file and set the number of loops to -1.
    // This means that the music will loop over and over. (And over and over...) :].
    func playBackgroundMusic(_ filename: String) {
        backgroundMusicPlayer = preloadSoundEffect(filename)
        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.play()
    }

    func playPopEffect(_ fileName: String) {
        popEffect = preloadSoundEffect(fileName)
        popEffect?.play()
    }

    func stopBackgroundMusic() {
        if backgroundMusicPlayer != nil {
            backgroundMusicPlayer?.stop()
            backgroundMusicPlayer = nil
        }
    }

}
