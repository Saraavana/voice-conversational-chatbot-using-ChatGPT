//
//  HistoryView.swift
//  Rammy Virtual Assistant
//
//  Created by Saravanakumar G on 13/07/23.
//

import SwiftUI

struct HistoryView: View {
    
    @Environment(\.dismiss) var dismiss
    let chatHistory :[EachChat]
    @Binding var chatMessages : [ChatMessage]
    @Binding var showHistory : Bool
    @Binding var chatID : UUID?

    
    var body: some View {
        List {
            ForEach(chatHistory) { history in
                Text(history.chat.first?.content ?? "")
                    .onTapGesture {
                        chatMessages = history.chat
                        chatID = history.id
                        showHistory.toggle()
                    }
            }
        }
    }
    
}

//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView(chatHistory: [EachChat(chat: [ChatMessage(id: "ds", content: "Sample", dateCreated: Date(), sender: .me)])], chatMessages: <#Binding<[ChatMessage]>#>)
//    }
//}
