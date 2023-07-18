//
//  ContentView.swift
//  Rammy Virtual Assistant
//
//  Created by Saravanakumar G on 13/07/23.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn: Bool = false
     
    var body: some View {
        if !isLoggedIn {
            LoginView(isLoggedIn: $isLoggedIn)
        } else {
            ChatView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoginView : View {
    
    @State private var email = ""
    @State private var password = ""
    
    @Binding var isLoggedIn: Bool
    
    @State private var isEmailValid: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.blue,.red], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack{
                Text("Welcome to Rammy Virtual Assistant")
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .offset(y: -150)
                Text("Ask anything, Get your answer")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .offset(y: -150)

                TextField("", text: $email)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty) {
                        Text("Email")
                            .foregroundColor(.white)
                            .bold()
                    }
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(.white)

                SecureField("", text: $password)
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: password.isEmpty) {
                        Text("Password")
                            .foregroundColor(.white)
                            .bold()
                    }
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(.white)

                Button {
                    // Sign in
                    if isValidEmail(email) && isValidPassword(password) {
                        isLoggedIn = true
                    }
                } label: {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.linearGradient(colors: [.blue], startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
                .padding()
                .offset(y:20)
                .disabled(!isValidEmail(email))
                .disabled(!isValidPassword(password))
            }
            .frame(width: 350)
        }
        .ignoresSafeArea()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.caseInsensitive])
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
//            let regex = try! NSRegularExpression(pattern: "^(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{8,}$", options: [])
//            return regex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.utf16.count)) != nil
    }
    
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
