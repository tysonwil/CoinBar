import Cocoa

protocol ImagesServiceProtocol {
    func getImage(for coin: Coin, completion: @escaping (Result<NSImage>) -> ())
}

final class ImagesService: ImagesServiceProtocol {
    
    private let networking: NetworkingProtocol
    private let cache = NSCache<NSString, NSImage>()

    init(networking: NetworkingProtocol) {
        self.networking = networking
    }
    
    func getImage(for coin: Coin, completion: @escaping (Result<NSImage>) -> ()) {
        
        if let cached = cachedImage(for: coin) {
            let result: Result<NSImage> = .success(cached)
            completion(result)
            return
        }
        
        let service = CoinWebService.coinImage(id: coin.id)
        
        networking.getData(at: service) { [weak self] result in
            guard let data = result.value,
                let image = NSImage(data: data) else {
                    let result: Result<NSImage> = .error("Image download failed")
                    completion(result)
                    return
            }

            self?.cacheImage(image, for: coin)
            
            let result: Result<NSImage> = .success(image)
            completion(result)
        }
        
    }
    
    private func cachedImage(for coin: Coin) -> NSImage? {
        let key = coin.id
        return cache.object(forKey: key as NSString)
    }
    
    private func cacheImage(_ image: NSImage, for coin: Coin) {
        let key = coin.id
        cache.setObject(image, forKey: key as NSString)
    }
}
