//
//  AiCellView.swift
//  OpenAI
//
//  Created by Eng.Omar Elsayed on 06/12/2023.
//

import SwiftUI

struct AiCellView: View {
    @EnvironmentObject var viewModel: OpenAIViewModel
    @State var isCopyPresed = false
    var message: deviceMessage
    var islast: Bool
    var pastboard = UIPasteboard.general
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .firstTextBaseline) {
                Text("Ai: ")
                    .foregroundStyle(Color(DesignResourses.ColorThem))
                    .fontDesign(.monospaced)
                    .padding(.vertical)
                
                Text(islast && viewModel.isTypingAnimation ? viewModel.response :message.content)
                    .foregroundStyle(Color(DesignResourses.ColorThem))
                    .fontDesign(.monospaced)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)
                    .overlay {
                        if viewModel.isloading && viewModel.response == "" && islast {
                            circuleAnimationView()
                        }
                    }
                
            }
            if !viewModel.isTypingAnimation && !viewModel.isloading {
                HStack {
                    Spacer()
                    Image(systemName: isCopyPresed ? "checkmark": "doc.on.doc")
                        .padding()
                        .onTapGesture {
                            withAnimation(.default){
                                isCopyPresed.toggle()
                                pastboard.string = message.content
                                DispatchQueue.main.asyncAfter(deadline:.now()+1.5) {
                                    isCopyPresed.toggle()
                                }
                            }
                        }
                }
            }
        }

    }
    
}

#Preview {
    AiCellView(message: deviceMessage(role: Role.assistant, content: ""), islast: true)
        .environmentObject(OpenAIViewModel())
}
