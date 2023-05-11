//
//  ListViewModel.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 10/05/23.
//

import UIKit

protocol ListViewModelProtocol {
    var didFetchRequest: (() -> Void)? { get set }
    func getSpeciesList() -> [Species]
    func getCurrentSpecies(at index: Int) -> Species
    func fetchSpecies()
    func fetchImage(at index: Int, completion: @escaping (UIImage?) -> Void)

}

class ListViewModel: ListViewModelProtocol {
    var didFetchRequest: (() -> Void)?
    
    private let requestHandler: RequestHandling
    private let imageHandler: ImageHandling

    private var species: [Species] = []
    private var limit: Int = 25
    private var offset: Int = 0
    private var shouldFetch: Bool = true
    
    init(requestHandler: RequestHandling, imageHandler: ImageHandling) {
        self.requestHandler = requestHandler
        self.imageHandler = imageHandler
    }
    
    func getSpeciesList() -> [Species] {
        return species
    }
    func getCurrentSpecies(at index: Int) -> Species {
        return species[index]
    }
    
    func fetchSpecies() {
        guard shouldFetch else { return }
        do {
            try requestHandler.request(route: .getSpeciesList(limit: limit, offset: offset)) { [weak self] (result: Result<SpeciesResponse, Error>) -> Void in
                guard let self else { return }
                switch result {
                case .success(let response):
                    self.species.append(contentsOf: response.results)
                    self.updatePagination(count: response.count)
                    self.didFetchRequest?()
                    
                case .failure:
                    print("TODO handle network failures")
                }
            }
        } catch {
            print("TODO handle request handling failures failures")
        }
    }
    
    private func updatePagination(count: Int) {
        self.offset += self.limit
        if self.offset > count {
            shouldFetch = false
        }
    }
    
    func fetchImage(at index: Int, completion: @escaping (UIImage?) -> Void) {
        let id = index + 1
        
        imageHandler.getImage(for: id) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(_):
                let placeholder = UIImage(named: "Image")
                completion(placeholder)
            }
        }
    }
}
