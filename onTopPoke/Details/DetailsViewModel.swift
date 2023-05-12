//
//  DetailsViewModel.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 10/05/23.
//

import UIKit

protocol DetailsViewModelProtocol {
    var didFetchRequest: (() -> Void)? { get set }
    var showAlert: ((String) -> Void)? { get set }
    
    func getSpeciesName() -> String
    func getEvolutionChain() -> EvolutionChainDetails?
    func getChainLinkSize() -> Int
    func getSpeciesImage() -> UIImage
    func fetchDetails()
    func getCurrentChain(at index: Int) -> ChainLink?
}

class DetailsViewModel: DetailsViewModelProtocol {
    var didFetchRequest: (() -> Void)?
    var showAlert: ((String) -> Void)?

    private let speciesImage: UIImage
    private let species: Species
    private var details: SpeciesDetails?
    private var evolutionChain: EvolutionChainDetails?
    private let requestHandler: RequestHandling

    init(species: Species,
         speciesImage: UIImage,
         requestHandler: RequestHandling) {
        self.species = species
        self.speciesImage = speciesImage
        self.requestHandler = requestHandler
    }
        
    func getSpeciesName() -> String {
        return species.name
    }
    
    func getEvolutionChain() -> EvolutionChainDetails? {
        return evolutionChain ?? nil
    }
    
    func getCurrentChain(at index: Int) -> ChainLink? {
        guard var currentChainLink = evolutionChain?.chain else { return nil }
        for _ in 0..<index {
            guard let nextChainLink = checkEvolution(chain: currentChainLink) else { return nil }
            currentChainLink = nextChainLink
        }
        return currentChainLink
    }
    
    func checkEvolution(chain: ChainLink) -> ChainLink? {
        if let currentChain = chain.evolvesTo.first(where: { link in link.species.name == species.name }) {
            return currentChain
        }
        if let currentChain = chain.evolvesTo.first {
            return currentChain
        }
        return nil
    }
    
    func getChainLinkSize() -> Int {
        guard let chain = evolutionChain?.chain else { return 0 }
        return countChainElements(chain: chain)
    }
    
    private func countChainElements(chain: ChainLink) -> Int {
        var count = 1
        for evolveTo in chain.evolvesTo {
            count += countChainElements(chain: evolveTo)
        }
        return count
    }
    
    func getSpeciesImage() -> UIImage {
        return speciesImage
    }
    
    func fetchDetails() {
        requestHandler.request(route: .getSpecies(species.url)) { [weak self] (result: Result<SpeciesDetails, Error>) -> Void in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.details = response
                self.fetchEvolutionChain()
            case .failure(let error):
                if let requestError = error as? RequestError {
                    self.showAlert?(requestError.asMessage())
                } else {
                    self.showAlert?(error.localizedDescription)
                }
            }
        }
        
    }
    
    func fetchEvolutionChain() {
        requestHandler.request(route: .getEvolutionChain(details!.evolutionChain.url)) { [weak self] (result: Result<EvolutionChainDetails, Error>) -> Void in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.evolutionChain = response
                self.didFetchRequest!()
            case .failure(let error):
                if let requestError = error as? RequestError {
                    self.showAlert?(requestError.asMessage())
                } else {
                    self.showAlert?(error.localizedDescription)
                }
            }
        }
    }

}
