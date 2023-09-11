//
//  EnglishConversationApp.swift
//  EnglishConversation
//
//  Created by Rakan on 2023/8/7.
//

import SwiftUI

@main
struct EnglishConversationApp: App {
    @StateObject private var apimanager = APIManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apimanager)
        }
    }
}
