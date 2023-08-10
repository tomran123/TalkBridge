//
//  Speech.swift
//  EnglishConversation
//
//  Created by Rakan on 2023/8/8.
//

import AVFoundation
import Speech

class SpeechRecognizer: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    @Published var isRecording = false
    @Published var recognizedText: String = "点击按钮开始识别"
    var onRecognizedTextUpdate: ((String) -> Void)?
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("授权成功")
            default:
                print("未获得授权")
            }
        }
    }

    func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("启动音频引擎出错: \(error)")
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                    self?.onRecognizedTextUpdate?(result.bestTranscription.formattedString)
                }

                if error != nil {
                    self?.stopRecording()
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
