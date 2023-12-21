//
//  MainView.swift
//  OpenAI
//
//  Created by Eng.Omar Elsayed on 11/12/2023.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: OpenAIViewModel
    @State var isPresented = false
    @FocusState var isfocus
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    var isConEmpty: Bool {
        viewModel.selectedConversation.chat.isEmpty
    }
    
    var body: some View {
        ZStack {
            SideMenu(isPresented: $isPresented)
                .ignoresSafeArea()
            VStack(alignment: isConEmpty ? .center: .leading) {
                if isConEmpty {
                    StartingView()
                }else {
                    ConversionView()
                }
                TextBarView()
            }
            .offset(x: isPresented ? screenWidth*0.85: 0.0)
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    viewModel.startaNewConverstion()
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.colorThem)
                }).disabled(isConEmpty)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    withAnimation(.default){
                        isPresented.toggle()
                    }
                }, label: {
                    Image(systemName: isPresented ? "multiply" : "text.alignleft")
                        .foregroundStyle(.colorThem)
                })
            }
        })
        .task {
           await viewModel.LoadChats()
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
            .environmentObject(OpenAIViewModel())
    }
}
