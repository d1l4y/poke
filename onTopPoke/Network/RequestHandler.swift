import UIKit

struct RequestError: Error {}

class RequestHandler: RequestHandling {
    func request<T>(route: APIRoute, completion: @escaping (Result<T, Error>) -> Void) throws {
        apiCall(url: route.asRequest()) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                completion(.success((self.parseData(data: data, route: route))))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func parseData<T>(data: Data, route: APIRoute) -> T {
        switch route {
        case .getSpecies(_):
            return parseGetSpeciesData(data: data) as! T
        case .getEvolutionChain(_):
            return parseEvolutionChainData(data: data) as! T
        case .getSpeciesList(_,_):
            return parseSpeciesListData(data: data) as! T
        case .getSpeciesImage(_):
            return parseImageFromData(data: data) as! T
        }
    }
    func parseImageFromData(data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else {
            print("Invalid response or data")
            return nil
        }
        return image
    }
                               
    func parseSpeciesListData(data: Data) -> SpeciesResponse? {
        let decoder = JSONDecoder()
        do {
            let items = try decoder.decode(SpeciesResponse.self, from: data)
            print(items)
            return items
        } catch {
            print("error \(error)")
            return nil
        }
    }
    
    func parseGetSpeciesData(data: Data) -> SpeciesDetails? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let items = try decoder.decode(SpeciesDetails.self, from: data)
            print(items)
            return items
        } catch {
            print("error \(error)")
            return nil
        }
    }
    
    func parseEvolutionChainData(data: Data) -> EvolutionChainDetails? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let items = try decoder.decode(EvolutionChainDetails.self, from: data)
            print(items)
            return items
        } catch {
            print("error \(error)")
            return nil
        }
    }
    
    func apiCall(url: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                completion(.success(data))
                return
            }
        }.resume()
    }
}
