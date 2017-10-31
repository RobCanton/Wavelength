/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The `MediaLibraryManager` manages creating and updating the `MPMediaPlaylist` that the application creates.
             It also serves as the data source of the `PlaylistTableViewController`
*/

import Foundation
import MediaPlayer

struct SongInfo {
    
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    var songId   :  NSNumber
    var dateAdded: Date
}

struct AlbumInfo {
    var albumID: String
    var albumTitle: String
    var albumArtist: String
    var albumArtistID: String
    var songs: [MPMediaItem]
    var dateAdded: Date
    var artwork:MPMediaItemArtwork?
    var genre:String?
    var year:Int?
}

func < (lhs: AlbumInfo, rhs: AlbumInfo) -> Bool {
    return lhs.dateAdded.compare(rhs.dateAdded) == .orderedAscending
}

func > (lhs: AlbumInfo, rhs: AlbumInfo) -> Bool {
    return lhs.dateAdded.compare(rhs.dateAdded) == .orderedDescending
}

func == (lhs: AlbumInfo, rhs: AlbumInfo) -> Bool {
    return lhs.dateAdded.compare(rhs.dateAdded) == .orderedSame
}

@objcMembers
class MediaLibraryManager: NSObject {
    
    // MARK: Types
    
    /// The Key for the `UserDefaults` value representing the UUID of the Playlist this sample creates.
    static let playlistUUIDKey = "playlistUUIDKey"
    
    /// Notification that is posted whenever the contents of the device's Media Library changed.
    static let libraryDidUpdate = Notification.Name("libraryDidUpdate")
    
    // MARK: Properties
    
    /// The instance of `AuthorizationManager` used for looking up the current device's Media Library and Cloud Services authorization status.
    let authorizationManager: AuthorizationManager
    
    /// The instance of `MPMediaPlaylist` that corresponds to the playlist created by this sample in the current device's Media Library.
    var mediaPlaylist: MPMediaPlaylist!
    
    // MARK: Initialization
    
    init(authorizationManager: AuthorizationManager) {
        self.authorizationManager = authorizationManager
        
        super.init()
        
        // Add the notification observers needed to respond to events from the `AuthorizationManager`, `MPMediaLibrary` and `UIApplication`.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification),
                                       name: AuthorizationManager.authorizationDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMediaLibraryDidChangeNotification),
                                       name: .MPMediaLibraryDidChange,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMediaLibraryDidChangeNotification),
                                       name: .UIApplicationWillEnterForeground,
                                       object: nil)
        
        handleAuthorizationManagerAuthorizationDidUpdateNotification()
    }
    
    deinit {
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMediaLibraryDidChange, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func getAlbum(_ id:MPMediaEntityPersistentID, completion: @escaping((_ album:AlbumInfo?)->())) {
        DispatchQueue.global(qos: .background).async {
            print("Querying for: \(id)")
            var albums: [AlbumInfo] = []
            let query = MPMediaQuery.albums()
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
            query.addFilterPredicate(predicate)
            let albumItems: [MPMediaItemCollection] = query.collections! as [MPMediaItemCollection]
            
            for album in albumItems {
                
                let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
                // var song: MPMediaItem
                
                var songs: [MPMediaItem] = []
                
                var albumID: String = ""
                var albumTitle: String = ""
                var albumArtist: String = ""
                var albumArtistID: String = ""
                var dateAdded = Date()
                var artwork:MPMediaItemArtwork!
                var albumGenre:String?
                
                for song in albumItems {
                    albumID = "\(song.value(forProperty: MPMediaItemPropertyAlbumPersistentID) as! NSNumber)"
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                    albumArtist = song.value( forProperty: MPMediaItemPropertyAlbumArtist ) as! String
                    albumArtistID = "\(song.value( forProperty: MPMediaItemPropertyAlbumArtistPersistentID ) as! NSNumber)"
                    dateAdded = song.value(forProperty: MPMediaItemPropertyDateAdded) as! Date
                    artwork = song.artwork
                    albumGenre = song.value(forProperty: MPMediaItemPropertyGenre) as? String
                    
                    songs.append( song )
                }
                
                let albumInfo: AlbumInfo = AlbumInfo(
                    albumID: albumID,
                    albumTitle: albumTitle,
                    albumArtist: albumArtist,
                    albumArtistID: albumArtistID,
                    songs: songs,
                    dateAdded: dateAdded,
                    artwork: artwork,
                    genre: albumGenre,
                    year: nil
                )
                
                albums.append( albumInfo )
            }
        
            DispatchQueue.main.async {
                if albums.count > 0 {
                    return completion(albums[0])
                } else {
                    return completion(nil)
                }
            }
        }
    }
    
    func searchMusicLibrarySongs(with search:String) -> [MPMediaItem] {
        let query = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: search, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains)
        query.addFilterPredicate(predicate)
        if let items = query.items as? [MPMediaItem] {
            return items
        }
        return []
        
    }
    
    func isSongInLibrary(_ song:MPMediaEntityPersistentID) -> Bool {
        guard let items = checkMediaLibrary(forSong: song) else { return false}
        return items.count > 0
    }
    
    func checkMediaLibrary(forSong song:MPMediaEntityPersistentID) -> [MPMediaItem]? {
        let query = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: song, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        return query.items
    }
    
    func getMusicLibrary(completion:@escaping(_ albums:[AlbumInfo])->()) {
        DispatchQueue.global(qos: .background).async {
            
            print("Async1")
            var albums: [AlbumInfo] = []
            let albumsQuery = MPMediaQuery.albums()


            let albumItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
            
            for album in albumItems {
                
                let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
                // var song: MPMediaItem
                
                var songs: [MPMediaItem] = []
                
                var albumID: String = ""
                var albumTitle: String = ""
                var albumArtist: String = ""
                var albumArtistID: String = ""
                var dateAdded = Date()
                var artwork:MPMediaItemArtwork!
                var albumGenre:String?
                var year:Int?
                
                for song in albumItems {
                    albumID = "\(song.value(forProperty: MPMediaItemPropertyAlbumPersistentID) as! NSNumber)"
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                    albumArtist = song.value( forProperty: MPMediaItemPropertyAlbumArtist ) as! String
                    albumArtistID = "\(song.value( forProperty: MPMediaItemPropertyAlbumArtistPersistentID ) as! NSNumber)"
                    dateAdded = song.value(forProperty: MPMediaItemPropertyDateAdded) as! Date
                    artwork = song.artwork
                    albumGenre = song.value(forProperty: MPMediaItemPropertyGenre) as? String
                    
                    if let yearNumber: NSNumber = song.value(forProperty: "year") as? NSNumber {
                        if (yearNumber.isKind(of: NSNumber.self)) {
                            let _year = yearNumber.intValue
                            if (_year != 0) {
                                year = _year
                            }
                        }
                    }
                    
                    songs.append( song )
                }
                
                let albumInfo: AlbumInfo = AlbumInfo(
                    albumID: albumID,
                    albumTitle: albumTitle,
                    albumArtist: albumArtist,
                    albumArtistID: albumArtistID,
                    songs: songs,
                    dateAdded: dateAdded,
                    artwork: artwork,
                    genre: albumGenre,
                    year: year
                )
                
                albums.append( albumInfo )
            }
            albums.sort { $0 > $1}
            DispatchQueue.main.async {
                completion(albums)
            }
        }
    }
    
    func createPlaylistIfNeeded() {
        
        guard mediaPlaylist == nil else { return }
        
        // To create a new playlist or lookup a playlist there are several steps you need to do.
        let playlistUUID: UUID
        
        var playlistCreationMetadata: MPMediaPlaylistCreationMetadata!
        
        let userDefaults = UserDefaults.standard
        
        if let playlistUUIDString = userDefaults.string(forKey: MediaLibraryManager.playlistUUIDKey) {
            // In this case, the sample already created a playlist in a previous run.  In this case we lookup the UUID that was used before.
            
            guard let uuid = UUID(uuidString: playlistUUIDString) else {
                fatalError("Failed to create UUID from existing UUID string: \(playlistUUIDString)")
            }
            
            playlistUUID = uuid
        } else {
            // Create an instance of `UUID` to identify the new playlist.
            playlistUUID = UUID()
            
            // Create an instance of `MPMediaPlaylistCreationMetadata`, this represents the metadata to associate with the new playlist.
            playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: "Test Playlist")
            
            playlistCreationMetadata.descriptionText = "This playlist was created using \(Bundle.main.infoDictionary!["CFBundleName"]!) to demonstrate how to use the Apple Music APIs"
            
            // Store the `UUID` that the sample will use for looking up the playlist in the future.
            userDefaults.setValue(playlistUUID.uuidString, forKey: MediaLibraryManager.playlistUUIDKey)
            userDefaults.synchronize()
        }
        
        // Request the new or existing playlist from the device.
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) { (playlist, error) in
            guard error == nil else {
                fatalError("An error occurred while retrieving/creating playlist: \(error!.localizedDescription)")
            }
            
            self.mediaPlaylist = playlist
            
            NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
        }
    }
    
    // MARK: Playlist Modification Method
    
    func addItem(with identifier: String) {
        
        guard let mediaPlaylist = mediaPlaylist else {
            fatalError("Playlist has not been created")
        }
        
        mediaPlaylist.addItem(withProductID: identifier, completionHandler: { (error) in
            guard error == nil else {
                fatalError("An error occurred while adding an item to the playlist: \(error!.localizedDescription)")
            }
            
            NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
        })
    }
    
    // MARK: Notification Observing Methods
    
    func handleAuthorizationManagerAuthorizationDidUpdateNotification() {
        
        if MPMediaLibrary.authorizationStatus() == .authorized {
            createPlaylistIfNeeded()
        }
    }
    
    func handleMediaLibraryDidChangeNotification() {
        
        if MPMediaLibrary.authorizationStatus() == .authorized {
            createPlaylistIfNeeded()
        }
        
        NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
    }
}
