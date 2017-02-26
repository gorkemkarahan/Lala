
import Foundation

final class User : ResponseObjectSerializable, ResponseCollectionSerializable {
    let id:Int
    let nickname:String
    let avatarUrl:String
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any]
            else { return nil }
   
        self.id = representation["id"] as! Int
        self.nickname = representation["nickname"] as! String
        self.avatarUrl = representation["avatarUrl"] as! String
    }
    
    init(id:Int, nickname:String, avatarUrl:String) {
        self.id = id
        self.nickname = nickname
        self.avatarUrl = avatarUrl
    }
}
