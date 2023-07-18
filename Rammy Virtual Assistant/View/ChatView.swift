//
//  ChatView.swift
//  Rammy Virtual Assistant
//
//  Created by Saravanakumar G on 13/07/23.
//

import SwiftUI
import Combine

struct ChatView: View {
//    @State var chatMessages : [ChatMessage] = ChatMessage.sampleMessages
    @State var chatMessages : [ChatMessage] = []
    @State var messageText: String = ""
    
    @State var chatHistories : [EachChat] = []
    @State var chatID = UUID(uuidString: "Hello World")
    
    @State var cancellables = Set<AnyCancellable>()
    @State private var showHistory = false
    
    @StateObject var conversation = Conversation()
    private var canStartConversation: Bool { conversation.state == .idle }
    private var canStopConversation: Bool { conversation.state == .listening }
    
    let openAIService = OpenAIService()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView{
                    LazyVStack{
                        ForEach(chatMessages, id: \.id) { message in
                            messageView(message: message)
                        }
                    }
                }
                
                HStack{
                    TextField("Enter a message", text: $messageText)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(12)
                    Button {
                        sendMessage()
                    } label: {
                        Label("", systemImage: "arrow.right.circle.fill")
                            .foregroundColor(.black)
                    }
                    if conversation.state != .listening {
                        Button {
                            //Voice
                            startListening()
                        } label: {
                            Label("", systemImage: "waveform.and.mic")
                                .foregroundColor(canStartConversation ? .black : .green)
                        }
                        .disabled(!canStartConversation)
                    } else {
                        Button {
                            //Voice
                            stopListening()
                            messageText = conversation.prompt
                            sendMessage()
                            
                        } label: {
                            Label("", systemImage: "waveform.and.mic")
                                .foregroundColor(canStopConversation ? .green : .black)
                        }
                        .disabled(!canStopConversation)
                    }
                }// End: HStack
            }// End: VStack
            .sheet(isPresented: $showHistory) {
                print("Presented")
            } content: {
                HistoryView(chatHistory: chatHistories, chatMessages: $chatMessages, showHistory: $showHistory, chatID: $chatID)
            }
            .padding()
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("History"){
                            if chatHistories.count > 0 {
                                if let chat_id = chatID {
                                    if let chat_index = chatHistories.firstIndex(where: {$0.id == chat_id}) {
                                        chatHistories[chat_index] = EachChat(chat: chatMessages)
                                    }
                                }
                                showHistory.toggle()
                            }
                        }
                        Button("New chat"){
                            if chatMessages.count > 0 {
                                if let chat_id = chatID {
                                    if let chat_index = chatHistories.firstIndex(where: {$0.id == chat_id}) {
                                        chatHistories[chat_index] = EachChat(chat: chatMessages)
                                        chatMessages = []
                                    }
                                }else {
                                    let chat = EachChat(chat: chatMessages)
                                    chatHistories.append(chat)
                                    chatMessages = []
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.rectangle.fill")
                        .resizable()
                        .frame(width: 40, height: 30)
                        .padding(10)
                        .foregroundColor(.black)
                    }
                }
            }//End: Toolbar
        }//End: NavigationView
    }
    
    func didDismiss() {
        // Handle the dismissing action.
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack {
            if message.sender == .me {Spacer()}
            Text(message.content)
                .foregroundColor(message.sender == .me ? .white : .black)
                .padding()
                .background(message.sender == .me ? .blue : .gray.opacity(0.1))
                .cornerRadius(16)
            if message.sender == .gpt {Spacer()}
        }
    }
    
    func sendMessage() {
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAIService.sendMessage(messages: chatMessages).sink { completion in
            //Handle error
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            chatMessages.append(gptMessage)
            
        }
        .store(in: &cancellables)
        messageText = ""
    }


    // Start listening (will start voice recognition)
    private func startListening() {
        conversation.startListening()
    }

    // Stop listening (will stop voice recognition)
    private func stopListening() {
        conversation.stopListening()
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

struct ChatMessage : Identifiable {
    let id: String
    let content : String
    let dateCreated: Date
    let sender: MessageSender
}

struct EachChat : Identifiable {
    let id = UUID()
    let chat :[ChatMessage]
}

enum MessageSender {
    case me
    case gpt
}

extension ChatMessage {
    static let sampleMessages = [
        ChatMessage(id: UUID().uuidString, content: "Sample message from me", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sampler message from gpt", dateCreated: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "Sample message from me", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sampler from gpt", dateCreated: Date(), sender: .gpt)
    ]
}
