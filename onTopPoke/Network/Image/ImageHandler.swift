//
//  ImageCacheHandler.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 11/05/23.
//

import UIKit

enum ImageHandlerError: Error {
    case urlError
    case decodingDataError
    case responseError
}

protocol ImageHandling {
    func getImage(for id: Int, completion: @escaping (Result<UIImage, ImageHandlerError>) -> Void)
}

class ImageHandler: ImageHandling {
    private let cache = NSCache<NSString, UIImage>()
    private var baseImagesURLString: String { "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" }
    
    init() {}
    
    func getImage(for id: Int, completion: @escaping (Result<UIImage, ImageHandlerError>) -> Void) {
        guard let imageUrl = getUrlFromId(id: id) else {
            completion(.failure(ImageHandlerError.urlError))
            return
        }
        
        let imageRequest = URLRequest(url: imageUrl)
        let key = imageUrl.absoluteString
        
        if let cachedImage = cache.object(forKey: key as NSString) {
            completion(.success(cachedImage))
            return
        }
        
        URLSession.shared.dataTask(with: imageRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(ImageHandlerError.responseError))
                return
            }
            if let image = UIImage(data: data) {
                self.cache.setObject(image, forKey: key as NSString)
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            }
        }.resume()
    }
    
    private func getUrlFromId(id:Int) -> URL? {
        return URL(string: self.baseImagesURLString + "\(id).png")
    }
    
}

