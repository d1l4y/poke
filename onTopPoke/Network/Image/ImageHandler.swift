//
//  ImageCacheHandler.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 11/05/23.
//

import UIKit

class ImageHandler: ImageHandling {
    private let cache = NSCache<NSString, UIImage>()
    private var baseImagesURLString: String { "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" }
    
    init() {}
    
    func getImage(for id: Int, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let imageUrl = getUrlFromId(id: id) else {
            let requestError = RequestError(type: .unknownError)
            completion(.failure(requestError))
            return
        }
        
        let imageRequest = URLRequest(url: imageUrl)
        let key = imageUrl.absoluteString
        
        if let cachedImage = cache.object(forKey: key as NSString) {
            completion(.success(cachedImage))
            return
        }
        
        URLSession.shared.dataTask(with: imageRequest) { (data, response, error) in
            if let error = error {
                let requestError = RequestError(type: .otherError(message: error.localizedDescription))
                completion(.failure(requestError))
            }
            
            if let data = data, let image = UIImage(data: data ) {
                self.cache.setObject(image, forKey: key as NSString)
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            } else {
                let requestError = RequestError(type: .decodingError)
                completion(.failure(requestError))
            }
            
        }.resume()
    }
    
    private func getUrlFromId(id:Int) -> URL? {
        return URL(string: self.baseImagesURLString + "\(id).png")
    }
    
}

