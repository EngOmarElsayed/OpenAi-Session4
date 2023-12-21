//
//  SubViews.swift
//  OpenAI
//
//  Created by Eng.Omar Elsayed on 20/12/2023.
//

import SwiftUI

struct SubMenuConversionsView: View {
    @EnvironmentObject var vm: OpenAIViewModel
    @Binding var isPresented: Bool
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(alignment:.leading, spacing: 20) {
            Button(action: {
                vm.startaNewConverstion()
                withAnimation(.default){
                    isPresented.toggle()
                }
            }, label: {
                Label("New Chat", systemImage: "square.and.pencil")
                    .foregroundStyle(.colorThem)
            }).disabled(vm.selectedConversation.chat.isEmpty)
            
            Divider()
                .frame(width: 240)
            
            VStack(alignment:.leading, spacing: 25){
                ForEach(vm.conversations) { con in
                    let isPressed = vm.selectedConversation.id == con.id
                    HStack {
                        Button {
                            vm.SwitchConversion(to: con)
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
                                withAnimation(.default){
                                    isPresented = false
                                }
                            }
                        } label: {
                            Text("\(con.title)")
                                .foregroundStyle(.colorThem)
                                .lineLimit(1)
                                .padding(.trailing,80)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.medium)
                        }.disabled(isPressed)
                        Spacer()
                        Button(action: {
                            Task{
                              await vm.DeletThis(chat: con.id)
                            }
                        }, label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .scaleEffect(x: 0.8, y: 0.8)
                        })
                    }.frame(width: screenWidth*0.6)
                }
            }
        }
    }
}

struct emptyConversions: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 25){
            Image(systemName: "bubble.left.and.bubble.right")
                .scaleEffect(x: 2.5,y: 2.5)
                .foregroundStyle(.colorThem)
            Text("All your chat's with OpenAi will appear\nhere but you don't have any chats yet.")
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
                .padding(.horizontal,20)
            
            Button(action: {
                withAnimation(.default){
                    isPresented.toggle()
                }
            }, label: {
                Text("Start a new Chat")
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.vertical,10)
                    .background(Color.init(red: 0, green: 0, blue: 245.0/255.0))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            })
            
        }
    }
}
