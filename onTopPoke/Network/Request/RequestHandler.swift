import UIKit

class RequestHandler: RequestHandling {
    func request<T>(route: APIRoute, completion: @escaping (Result<T, Error>) -> Void) {
        apiCall(url: route.asRequest()) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                guard let parsedData: T = self.parseData(data: data, route: route) else {
                    completion(.failure(RequestError(code: 0, type: .decodingError)))
                    return
                }
                completion(.success(parsedData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func parseData<T>(data: Data, route: APIRoute) -> T {
        switch route {
        case .getSpecies(_):
            return parseGetSpeciesData(data: data) as! T
        case .getEvolutionChain(_):
            return parseEvolutionChainData(data: data) as! T
        case .getSpeciesList(_,_):
            return parseSpeciesListData(data: data) as! T
        }
    }
                               
    private func parseSpeciesListData(data: Data) -> SpeciesResponse? {
        let decoder = JSONDecoder()
        do {
            let items = try decoder.decode(SpeciesResponse.self, from: data)
            return items
        } catch {
            return nil
        }
    }
    
    private func parseGetSpeciesData(data: Data) -> SpeciesDetails? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let items = try decoder.decode(SpeciesDetails.self, from: data)
            return items
        } catch {
            return nil
        }
    }
    
    private func parseEvolutionChainData(data: Data) -> EvolutionChainDetails? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let items = try decoder.decode(EvolutionChainDetails.self, from: data)
            return items
        } catch {
            return nil
        }
    }
    
    func apiCall(url: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                if let urlError = error as? URLError, urlError.code == URLError.notConnectedToInternet {
                    let requestError = RequestError(code: 0, type: .noInternet)
                    completion(.failure(requestError))
                }
                
                let requestError = RequestError(code: 0, type: .otherError(message: error.localizedDescription))
                completion(.failure(requestError))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else  {
                let requestError = RequestError(code: 0, type: .unknownError)
                completion(.failure(requestError))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let requestError = RequestError(code: httpResponse.statusCode, type: .invalidStatusCode)
                 completion(.failure(requestError))
                 return
             }
            
            if let data = data {
                completion(.success(data))
                return
            }
        }.resume()
    }
}
