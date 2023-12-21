//
//  OpenAIViewModel.swift
//  OpenAI
//
//  Created by Eng.Omar Elsayed on 05/12/2023.
//

import Foundation

@MainActor class OpenAIViewModel: ObservableObject {
    @Published var message = ""
    @Published var response = ""
    @Published var welcomeText = ""
    @Published var isloading = false
    @Published var selectedConversation: Conversion = Conversion(chat: [])
    @Published var conversations: [Conversion] = []
    @Published var isTypingAnimation = false
    
    var Index: Int {
        conversations.firstIndex(where: {$0.id == selectedConversation.id }) ?? 0
    }
    
    var lastIndex: Int {
        selectedConversation.chat.count-1
    }
    
   private let apiManger = APiManger.shared
   private let fileDataManger = DataManger.shared
}


//- MARK: public functions
extension OpenAIViewModel {
    func welcomeAnimation() {
        TypoAnimation(for: "How Can I help you today ?", isWelcome: true)
    }
    
    func startaNewConverstion() {
        let index = conversations.firstIndex(where: {$0.id == selectedConversation.id})
        if let index = index {
            conversations[index] = selectedConversation
        }
        selectedConversation = Conversion(chat: [])
    }
    
    func SwitchConversion(to con: Conversion) {
        let index = conversations.firstIndex(where: {$0.id == selectedConversation.id})
        if let index = index {
            conversations[index] = selectedConversation
        }
        selectedConversation = con
        response = con.chat[con.chat.endIndex-1].content
    }
    
}

//- MARK: Data functions

extension OpenAIViewModel {
    
    func LoadChats() async {
      conversations = await fileDataManger.load() ?? conversations
    }
    
    func SaveChat() async {
        conversations[Index] = selectedConversation
       await fileDataManger.save(this: conversations)
    }
    
    func DeletThis(chat id: UUID) async {
        conversations.removeAll(where: {$0.id == id})
        await fileDataManger.save(this: conversations)
    }
    
}

//- MARK: Api request functions
extension OpenAIViewModel {
    
    func sendMessage() async throws {
        selectedConversation.chat.append(deviceMessage(role: Role.user, content: message))
        selectedConversation.chat.append(deviceMessage(role: Role.assistant, content: ""))
        if selectedConversation.chat.count <= 2 { conversations.append(selectedConversation) }
        message = ""
        response = ""
        isloading = true
        try await sendApiMessage()
        await SaveChat()
    }
    
   private func sendApiMessage() async throws {
        do {
            let response = try await request()
            selectedConversation.chat[selectedConversation.chat.endIndex-1].content = response.choices[0].message.content
            isloading = false
            TypoAnimation(for: response.choices[0].message.content, isWelcome: false)
            
        }catch{
            print(error.localizedDescription)
            isloading = false
            selectedConversation.chat[selectedConversation.chat.endIndex-1].content = "There is an error, please check your internat connection."
            TypoAnimation(for: "There is an error, please check your internat connection. ", isWelcome: false)
        }
        
    }
    
   private func request() async throws -> AiResponse {
        try await apiManger.makeRequest(message: selectedConversation.chat)
    }
    
}

//- MARK: Typing Animation
extension OpenAIViewModel {
    
    private func TypoAnimation(for text: String, isWelcome: Bool) {
        var charindex = 0.0
        var typingSpeed = 0.02
        let loopOn = text+" "
        
        if isWelcome {
            welcomeText = ""
            typingSpeed = 0.08
        }else {
            isTypingAnimation = true
        }
        
        for letter in loopOn {
            Timer.scheduledTimer(withTimeInterval: typingSpeed*charindex, repeats: false) { timer in
                _ = isWelcome ? self.welcomeText.append(letter): self.response.append(letter)
                if loopOn.count == self.response.count {
                    self.isTypingAnimation = false
                }
            }
            charindex += 1
        }   
    }
}

