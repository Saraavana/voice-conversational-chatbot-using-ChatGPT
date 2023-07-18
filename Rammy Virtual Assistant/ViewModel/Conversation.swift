//
//  Conversation.swift
//  Rammy Virtual Assistant
//
//  Created by Saravanakumar G on 13/07/23.
//

import Foundation

class Conversation : ObservableObject {
    
//    struct Chat : Identifiable {
//        let id = UUID()
//        let inputText: String
//        let answer : String
//    }
    
    enum State {
        case idle
        case listening
    }
    
//    @Published var chatLogs = [Chat]()
    @Published var state: State = .idle
    @Published var prompt = ""
    
    func startListening() {
        state = .listening
        Synthesizer.shared.stopSpeaking()
        SpeechRecognizer.shared.startRecording { text in
            self.prompt = text
        }
    }
    
    func stopListening() {
        state = .idle
        SpeechRecognizer.shared.stopRecording()
    }
}
