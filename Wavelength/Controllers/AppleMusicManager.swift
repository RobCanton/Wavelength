/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`AppleMusicManager` manages creating making the Apple Music API calls for the `MediaSearchTableViewController`.
*/

import Foundation
import StoreKit
import UIKit

class AppleMusicManager {
    
    // MARK: Types

    /// The completion handler that is called when an Apple Music Catalog Search API call completes.
    typealias CatalogSearchCompletionHandler = (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void
    
    /// The completion handler that is called when an Apple Music Get User Storefront API call completes.
    typealias GetUserStorefrontCompletionHandler = (_ storefront: String?, _ error: Error?) -> Void
    
    /// The completion handler that is called when an Apple Music Get Recently Played API call completes.
    typealias GetRecentlyPlayedCompletionHandler = (_ mediaItems: [MediaItem], _ error: Error?) -> Void
    
    // MARK: Properties
    
    /// The instance of `URLSession` that is going to be used for making network calls.
    lazy var urlSession: URLSession = {
        // Configure the `URLSession` instance that is going to be used for making network calls.
        let urlSessionConfiguration = URLSessionConfiguration.default
        
        return URLSession(configuration: urlSessionConfiguration)
    }()
    
    /// The storefront id that is used when making Apple Music API calls.
    var storefrontID: String?
    
    func fetchDeveloperToken() -> String? {
        
        // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD
        let developerAuthenticationToken: String? = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkVCOVEzWjkySkQifQ.eyJpYXQiOjE1MDcxNTM0MzAsImV4cCI6MTUyMjcwNTQzMCwiaXNzIjoiNkJFUzNWVUZDWCJ9.jpBHEBgTWTDlpTZbeVhYdV-BHpfEWMYZZseYR8jeehU2cwtL2Bdy3kCdY1ERRdlzhwQKC5L3TEWjTwiS9zompw"
        return developerAuthenticationToken
    }
    
    // MARK: General Apple Music API Methods
    
    func performSongRequest(songID: String, countryCode:String, completion:@escaping((_ item:MediaItem?)->())) {
        guard let developerToken = fetchDeveloperToken() else {
            print("Developer Token not configured. See README for more details.")
            return completion(nil)
        }
        
        let urlRequest = AppleMusicRequestFactory.createSongRequest(id: songID, countryCode: countryCode, developerToken: developerToken)
        print("Req: \(urlRequest)")
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                //completion([], error)
                print("Damn!: \(error?.localizedDescription)")
                return completion(nil)
            }
            
            do {
                //print("DATA!: \(data)")
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let data = jsonDictionary["data"] as? [[String:Any]], let first = data.first else {
                    print("DAMN")
                    return
                }
                //print("FIRST: \(first)")
                let mediaItem = try MediaItem(json: first)
                print(mediaItem)
                do {
                    let mediaItem = try MediaItem(json: first)
                    return completion(mediaItem)
                } catch {
                    return completion(nil)
                }
                
            } catch {
                return completion(nil)
            }
        }
        
        task.resume()
    }
    
    func performArtistSearchRequest(artistID: String, countryCode:String, completion: @escaping((_ success:Bool, _ albums:[String]?)->())) {
        guard let developerToken = fetchDeveloperToken() else {
            print("Developer Token not configured. See README for more details.")
            completion(false, nil)
            return
        }
        
        let urlRequest = AppleMusicRequestFactory.createArtistSearchRequest(with: artistID, countryCode: countryCode, developerToken: developerToken)
        print("Req: \(urlRequest)")
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                //completion([], error)
                print("Damn!: \(error?.localizedDescription)")
                completion(false, nil)
                return
            }
            
            do {
                //print("DATA!: \(data)")
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let results = jsonDictionary["results"] as? [String:Any],
                    let artists = results["artists"] as? [String:Any],
                    let artistsArray = artists["data"] as? NSArray,
                    let first = artistsArray.firstObject as? [String: Any],
                    let id = first["id"] as? String else {
                        
                    completion(false, nil)
                    return
                }
                print("id: \(id)")
                
                let artistRequest = AppleMusicRequestFactory.createArtistRequest(id: id, countryCode: countryCode, developerToken: developerToken)
                
                let artistTask = self.urlSession.dataTask(with: artistRequest) { (data, response, error) in
                    guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                        //completion([], error)
                        print("Damn!: \(error?.localizedDescription)")
                        completion(false, nil)
                        return
                    }
                    
                    do {
                        //print("DATA!: \(data)")
                        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                            let artistData = jsonDictionary["data"] as? NSArray,
                            let first = artistData.firstObject as? [String:Any],
                            let relationships = first["relationships"] as? [String:Any],
                            let albums = relationships["albums"] as? [String:Any],
                            let albumsDictionary = albums["data"] as? [[String:Any]] else {
                                return
                        }
                        var albumIDsArray = [String]()
                        for item in albumsDictionary {
                            if let albumID = item["id"] as? String {
                                albumIDsArray.append(albumID)
                            }
                        }
                        
                        completion(true, albumIDsArray)
                    } catch {
                        completion(false, nil)
                        
                    }
                }
                artistTask.resume()
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured. See README for more details.")
        }
        print("performing Apple Music Catalog Search with term '\(term)' in country '\(countryCode)'")
        let urlRequest = AppleMusicRequestFactory.createSearchRequest(with: term, countryCode: countryCode, developerToken: developerToken)
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                return
            }
            
            do {
                let mediaItems = try self.processMediaItemSections(from: data!)
                completion(mediaItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func performAppleMusicStorefrontsLookup(regionCode: String, completion: @escaping GetUserStorefrontCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured. See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createStorefrontsRequest(regionCode: regionCode, developerToken: developerToken)
        
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion(nil, error)
                return
            }
            
            do {
                let identifier = try self?.processStorefront(from: data!)
                completion(identifier, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    // MARK: Personalized Apple Music API Methods
    
    func performAppleMusicGetRecentlyPlayed(userToken: String, completion: @escaping GetRecentlyPlayedCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured.  See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createRecentlyPlayedRequest(developerToken: developerToken, userToken: userToken)
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                
                return
            }
            
            do {
                guard let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let results = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                        throw SerializationError.missing(ResponseRootJSONKeys.data)
                }
                
                print("RESUTS: \(results)")
                let mediaItems = try self.processMediaItems(from: results)
                
                completion(mediaItems, nil)
                
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func performAppleMusicGetUserStorefront(userToken: String, completion: @escaping GetUserStorefrontCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            fatalError("Developer Token not configured.  See README for more details.")
        }
        
        let urlRequest = AppleMusicRequestFactory.createGetUserStorefrontRequest(developerToken: developerToken, userToken: userToken)
        
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                let error = NSError(domain: "AppleMusicManagerErrorDomain", code: -9000, userInfo: [NSUnderlyingErrorKey: error!])
                
                completion(nil, error)
                
                return
            }
            
            do {
                
                let identifier = try self?.processStorefront(from: data!)
                
                completion(identifier, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func processMediaItemSections(from json: Data) throws -> [[MediaItem]] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        
        var mediaItems = [[MediaItem]]()
        
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(songMediaItems)
            }
        }
        
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
            }
        }
        
        return mediaItems
    }
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        print("PROCESSMEDIAITEMS: \(json)")
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processStorefront(from json: Data) throws -> String {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        
        guard let identifier = data.first?[ResourceJSONKeys.identifier] as? String else {
            throw SerializationError.missing(ResourceJSONKeys.identifier)
        }
        
        return identifier
    }
}
