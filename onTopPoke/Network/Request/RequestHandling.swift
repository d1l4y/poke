import Foundation

protocol RequestHandling {
    func request<T>(route: APIRoute, completion: @escaping (Result<T, Error>) -> Void)
}
