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
}

class ListViewModel: ListViewModelProtocol {
    var didFetchRequest: (() -> Void)?

    private let requestHandler: RequestHandling = RequestHandler()
    private var species: [Species] = []
    
    func getSpeciesList() -> [Species] {
        return species
    }
    func getCurrentSpecies(at index: Int) -> Species {
        return species[index]
    }
    
    func fetchSpecies() {
        do {
            // TODO Consider pagination
            try requestHandler.request(route: .getSpeciesList(limit: 20, offset: 0)) { [weak self] (result: Result<SpeciesResponse, Error>) -> Void in
                guard let self else { return }
                switch result {
                case .success(let response):
                    self.species = response.results
                    self.didFetchRequest!()
                case .failure:
                    print("TODO handle network failures")
                }
            }
        } catch {
            print("TODO handle request handling failures failures")
        }
    }
}
