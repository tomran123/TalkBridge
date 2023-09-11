//
//  SetApi.swift
//  EnglishConversation
//
//  Created by Rakan on 2023/8/30.
//

import SwiftUI
import ChatGPTSwift


class APIManager: ObservableObject {
    @Published var api = ChatGPTAPI(apiKey: "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")
}


struct SetApi: View {
    @EnvironmentObject var apiManager: APIManager // 引入环境对象
    @State private var apiKey: String = "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"

    var body: some View {
        VStack {
            TextField("API Key", text: $apiKey) // 修改环境对象中的 api 值

            Button(action: {
                apiManager.api = ChatGPTAPI(apiKey: apiKey)
                print("新的 API 值为: \(apiKey)")
            }) {
                Text("保存")
            }
        }
    }
}
