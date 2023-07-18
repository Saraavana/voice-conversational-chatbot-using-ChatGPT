//
//  OpenAIService.swift
//  Rammy Virtual Assistant
//
//  Created by Saravanakumar G on 13/07/23.
//

import Foundation
import Alamofire
import Combine

class OpenAIService {
//    let baseUrl = "https://api.openai.com/v1/completions"
    let baseUrl = "https://api.openai.com/v1/chat/"
    
    
//    func sendMessage(messages: [[String:String]]) -> AnyPublisher<OpenAICompletionsResponse, Error> {
//    func sendMessage(messages: [EachMessage]) -> AnyPublisher<OpenAICompletionsResponse, Error> {
    func sendMessage(messages: [ChatMessage]) -> AnyPublisher<OpenAICompletionsResponse, Error> {
//    func sendMessage(message: String) -> AnyPublisher<OpenAICompletionsResponse, Error> {
//    func sendMessage(message: String) {

        
        var all_messages : [[String:String]] = []
//        for each in messages {
//            var each_message :[String:String] = [:]
//            each_message["role"] = each.role
//            each_message["content"] = each.content
//            all_messages.append(each_message)
//        }
        
        for each in messages {
            var each_message :[String:String] = [:]
            each_message["role"] = each.sender == .me ? "user" : "assistant"
            each_message["content"] = each.content
            all_messages.append(each_message)
        }
        
        
        let prompt_messages = all_messages
        let body = OpenAICompletionsBody(model: "gpt-3.5-turbo", messages: prompt_messages, temperature: 0, max_tokens: 256)
        let headers :HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        
        let realURL: URL = URL(string: baseUrl + "completions")!
        
        return Future { promise in
            AF.request(realURL, method: .post, parameters: body, encoder: .json, headers: headers).responseDecodable(of: OpenAICompletionsResponse.self) { response in
                print(response.result)
                switch response.result {
                case .success(let result):
                    promise(.success(result))
                case .failure(let error):
                    promise(.failure(error))
                }

            }
        }
        .eraseToAnyPublisher()
        
        
//        let prompt_messages = [["role": "user", "content": message]]
//        let body = OpenAICompletionsBody(model: "gpt-3.5-turbo", messages: prompt_messages, temperature: 0, max_tokens: 256)
//        let headers :HTTPHeaders = [
//            "Authorization": "Bearer \(Constants.openAIAPIKey)"
//        ]
//
//        let realURL: URL = URL(string: baseUrl + "completions")!
//
//        AF.request(realURL, method: .post, parameters: body, encoder: .json, headers: headers).responseJSON { response in
//            print(response.result)
//        }
//
//        return Future { [weak self] promise in
//            guard let self = self else {return}
//            AF.request(realURL, method: .post, parameters: body, encoder: .json, headers: headers).responseDecodable(of: OpenAICompletionsResponse.self) { response in
////                print(response.result)
//                switch response.result {
//                case .success(let result):
//                    promise(.success(result))
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//
//            }
//        }
//        .eraseToAnyPublisher()
    }
}

struct OpenAICompletionsBody: Encodable {
    let model :String
    let messages: [[String:String]]
//    let messages: String
    let temperature: Float?
    let max_tokens: Int?
}

struct OpenAICompletionsResponse: Decodable {
    let id: String
    let choices: [OpenAICompletionschoice]
}

struct OpenAICompletionschoice: Decodable {
    let message: OpenAIMessage
}

struct OpenAIMessage: Decodable {
    let role: String
    let content: String
}
