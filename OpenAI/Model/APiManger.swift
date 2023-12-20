//
//  APiManger.swift
//  OpenAI
//
//  Created by Eng.Omar Elsayed on 05/12/2023.
//

import Foundation

class APiManger {
    let apiKey = "YourKey" // your api key.
    let urlString = "https://api.openai.com/v1/chat/completions" // api url
    static let shared = APiManger()
}

extension APiManger {
    
    func makeRequest(message: [deviceMessage]) async throws -> AiResponse {
        guard let url = URL(string: urlString) else {throw String.errorInURL}
        
        let messages = ConvertThis(message)
        
        let request = ConfigureURLSession(for: url, message: messages)
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard (response as! HTTPURLResponse).statusCode == 200 else {
            print((response as! HTTPURLResponse).statusCode)
            throw String.serverError.localizedDescription
        }
        
        return try JSONDecoder().decode(AiResponse.self, from: data)
    }
    
}

extension APiManger {
    private func ConfigureURLSession(for url: URL, message: [SentMessage]) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        
        let usermessage = message
        let request = RequestData(model: "gpt-3.5-turbo", messages: usermessage)
        let body = JSONEncoder().Encode(request)
        
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        urlRequest.httpBody = body
        
        return urlRequest
    }
    
    private func ConvertThis(_ array: [deviceMessage]) -> [SentMessage] {
        var result = array.convertToMessage()
        result.insert(SentMessage(role: Role.system, content: "You are a helpful assistant"), at: 0)
        return result
    }
    
}
