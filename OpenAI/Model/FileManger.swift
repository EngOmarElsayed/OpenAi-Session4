//
//  FileManger.swift
//  OpenAI
//
//  Created by Eng.Omar Elsayed on 20/12/2023.
//

import Foundation

class DataManger {
    static let shared = DataManger()
    
    var documentUrl: URL {
        do{
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }catch{
            fatalError("\(error.localizedDescription)")
        }
    }
    
    var chatsFile: URL {
        documentUrl.appendingPathComponent("chatsFile", conformingTo: .json)
    }
    
}

extension DataManger {
    
    func load() async -> [Conversion]? {
        guard FileManager.default.isReadableFile(atPath: chatsFile.path()) else {return nil}
        
        do {
            let data = try Data(contentsOf: chatsFile)
            return try JSONDecoder().decode([Conversion].self, from: data)
        }catch{
           print(error.localizedDescription)
           return nil
        }
    }
    
    func save(this chats: [Conversion]) async {
        
        do {
            let data = try JSONEncoder().encode(chats)
            try data.write(to: chatsFile)
        }catch{
            print(error.localizedDescription)
        }
        
    }
}
