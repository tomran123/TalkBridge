//
//  ContentView.swift
//  EnglishConversation
//
//  Created by Rakan on 2023/8/7.
//

import SwiftUI
import AVFoundation
import Speech
import ChatGPTSwift




struct ContentView: View {
    @State private var inputText = ""
    @State private var messages: [Message] = []
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder!
    @State private var speechRecognizer = SFSpeechRecognizer()
    @ObservedObject var recognizer = SpeechRecognizer()
    @State private var currentRecordingMessageID: UUID?
    @State private var textSend = ""
    private var synthesizer = AVSpeechSynthesizer()
    
    
    
    @EnvironmentObject var apiManager: APIManager // 引入环境对象
    var api = ChatGPTAPI(apiKey: "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")
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                Text("AI英语口语练习应用")
                Divider()
                    .frame(height: 1.0)
                
                
                ScrollView {
                    Spacer()
                    ForEach(messages) { message in
                        HStack(alignment: .top, content: {
                            
                            if message.isFromUser{
                                ZStack {
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.orange)
                                    Text("ME")
                                        .font(.title2)
                                        .foregroundColor(Color.white)
                                    
                                }
                            }else{
                                ZStack {
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.green)
                                    Text("AI")
                                        .font(.title2)
                                        .foregroundColor(Color.white)
                                }
                            }
                            Text(message.text)
                                .padding(.all)
                                .background(.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .frame(alignment: .leading)
                            Spacer()
                        })
                        .padding(.leading, 10.0)
                    }
                }
                
                HStack(spacing: 1.0) {
                    Button(action:{
                        if recognizer.isRecording {
                            recognizer.stopRecording()
                            let processingMessage = Message(text: "processing...", isFromUser: false)
                            messages.append(processingMessage)
                            Task{
                                do {
                                    let response = try await api.sendMessage(text: textSend)
                                    if let index = messages.firstIndex(where: { $0.text == "processing..." }) {
                                        messages.remove(at: index)
                                    }
                                    let newMessage = Message(text: response, isFromUser: false)
                                    messages.append(newMessage)
                                    print(response)
                                    let utterance = AVSpeechUtterance(string: response)  // Use the API response
                                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                                    utterance.volume = 20.0  // Set the volume (optional)
                                    synthesizer.speak(utterance)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                            
                        } else {
                            let newMessage = Message(text: "recording...", isFromUser: true)
                            messages.append(newMessage)
                            currentRecordingMessageID = newMessage.id
                            
                            recognizer.onRecognizedTextUpdate = { updatedText in
                                if let index = messages.firstIndex(where: { $0.id == currentRecordingMessageID }) {
                                    messages[index].text = updatedText
                                    textSend=messages[index].text
                                }
                            }
                            
                            
                            recognizer.startRecording()
                        }
                        recognizer.isRecording.toggle()
                    }) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.white)
                            Text(recognizer.isRecording ? "正在说话" : "开始录音")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(recognizer.isRecording ? Color.green : Color.blue)
                        .cornerRadius(10)
                    }
                    Spacer()
                        .frame(width: 9.0)
                    Button(action:{
                        messages=[]
                        api.deleteHistoryList()
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                            Text("删除对话")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    
                }
                .padding()
                .onAppear(perform: {
                    recognizer.requestAuthorization()
                })
                
                NavigationLink(destination: SetApi()) {
                    Text("Go to Modify API")
                }
                
            }
        }.navigationBarTitle("Main View")
    }
}

struct Message: Identifiable {
    let id = UUID()
    var text: String
    let isFromUser: Bool
}
