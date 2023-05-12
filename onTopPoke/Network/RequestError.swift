//
//  RequestError.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 11/05/23.
//

import Foundation

struct RequestError: Error {
    let code: Int
    let type: RequestErrorType

    init(code: Int = 0, type: RequestErrorType) {
        self.code = code
        self.type = type
    }
    
    func asMessage() -> String {
        switch type {
        case .unknownError,
                .otherError(_):
            return "Oops! Something went wrong. Please try again later."
        case .invalidStatusCode:
            return "Oops! We're having trouble communicating with our servers. Please try again later."
        case .decodingError:
            return "Oops! We're having trouble processing the data we received. Please try again later."
        case .noInternet:
            return "Oops! It looks like you don't have an internet connection. Please connect to the internet and try again."
        }
    }
}

enum RequestErrorType {
    case unknownError
    case invalidStatusCode
    case decodingError
    case noInternet
    case otherError(message: String)

}
