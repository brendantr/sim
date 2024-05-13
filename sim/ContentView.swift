//
//  ContentView.swift
//  sim
//
//  Created by Brendan  Rodriguez on 5/11/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var audioPlayers: [AVAudioPlayer?] = [nil, nil]
    @State private var isPlaying: [Bool] = [false, false]
    @State private var selectedTrack: String?
    @State private var volume: [Float] = [0.5, 0.5]
    @State private var time: TimeInterval = 0.0
    @State private var duration: TimeInterval = 0.0
    let musicTracks = ["track1", "track2"] // Only track1 and track2

    var body: some View {
        ZStack {
            
            NavigationView {
                VStack(spacing: 20) { // Added spacing between each track
                    ForEach(musicTracks.indices, id: \.self) { index in
                        VStack {
                            
                            // COLOR FEATURE!
                            LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                           startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/,
                                           endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                            
                            HStack {
                                
                                Text(musicTracks[index])
                                Spacer()
                                if isPlaying[index] {
                                    Button(action: { pause(trackIndex: index) }) {
                                        Image(systemName: "pause.circle.fill")
                                            .font(.title)
                                    }
                                    .padding(.trailing)
                                } else {
                                    Button(action: { play(trackIndex: index) }) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title)
                                    }
                                    .padding(.trailing)
                                }
                            }
                            .padding(.horizontal)
                            
                            Slider(value: $volume[index], in: 0.0...1.0)
                                .padding(.horizontal)
                                .onChange(of: volume[index]) { value in
                                    adjustVolume(trackIndex: index)
                                }
                            
                            HStack {
                                
                                Button(action: { rewind(trackIndex: index) }) {
                                    Image(systemName: "backward.fill")
                                        .font(.title)
                                }
                                .padding(.leading)
                                
                                Spacer()
                                
                                Button(action: { fastForward(trackIndex: index) }) {
                                    Image(systemName: "forward.fill")
                                        .font(.title)
                                }
                                .padding(.trailing)
                            }
                            
                        }
                        
                    }
                    .navigationBarTitle("Simulisten")
                    .navigationBarTitleDisplayMode(.inline) // Set title display mode
                    .toolbar {
                        // You can adjust the font and other properties here
                        ToolbarItem(placement: .principal) {
                            Text("Simulisten")
                                .font(.custom("YourCoolTechFont", size: 24)) // Set the custom font
                        }
                    }
                    
                    
                    if selectedPlayer() != nil {
                        Text("Time: \(timeFormatted(time: time)) / \(timeFormatted(time: duration))")
                            .padding()
                            .onAppear {
                                startTimer()
                            }
                    }
                }
            }
        }
    }


    private func play(trackIndex: Int) {
        guard let url = Bundle.main.url(forResource: musicTracks[trackIndex], withExtension: "mp3") else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
            player.volume = volume[trackIndex]
            audioPlayers[trackIndex] = player
            isPlaying[trackIndex] = true
            duration = player.duration
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    private func pause(trackIndex: Int) {
        guard let player = audioPlayers[trackIndex] else {
            return
        }
        
        player.pause()
        isPlaying[trackIndex] = false
    }
    
    private func adjustVolume(trackIndex: Int) {
        if let player = audioPlayers[trackIndex] {
            player.volume = volume[trackIndex]
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = selectedPlayer() {
                time = player.currentTime
            }
        }
    }
    
    private func selectedPlayer() -> AVAudioPlayer? {
        if let selectedTrack = selectedTrack, let index = musicTracks.firstIndex(of: selectedTrack) {
            return audioPlayers[index]
        }
        return nil
    }
    
    private func timeFormatted(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func fastForward(trackIndex: Int) {
        if let player = audioPlayers[trackIndex] {
            let currentTime = player.currentTime
            let newTime = min(currentTime + 10, player.duration) // Forward by 10 seconds
            player.currentTime = newTime
            time = newTime
        }
    }

    private func rewind(trackIndex: Int) {
        if let player = audioPlayers[trackIndex] {
            let currentTime = player.currentTime
            let newTime = max(currentTime - 10, 0) // Rewind by 10 seconds
            player.currentTime = newTime
            time = newTime
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
