//
//  Message.swift
//  Lala
//
//  Created by Görkem Karahan on 22/02/2017.
//  Copyright © 2017 Görkem Karahan. All rights reserved.
//

import Foundation

final class Message : ResponseObjectSerializable, ResponseCollectionSerializable {
    let id:Int
    let text:String
    let timeStamp:Double
    let user:User
    let messageDateTime:String
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any]
            else { return nil }

        self.id = representation["id"] as! Int
        self.text = representation["text"] as! String
        self.timeStamp = representation["timestamp"] as! Double
        self.messageDateTime = GlobalUtilities.sharedInstance.dateFormatter.string(from:(Date(timeIntervalSince1970: self.timeStamp)))
        self.user = User(response:response, representation:representation["user"]!)!
    }
    
    init(id:Int, text:String, timeStamp:Double, user:User) {
        self.id = id
        self.text = text
        self.timeStamp = timeStamp
        self.user = user
        self.messageDateTime = GlobalUtilities.sharedInstance.dateFormatter.string(from:(Date(timeIntervalSince1970: self.timeStamp)))
    }
    
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Message] {
        let messages = (representation as! [String:Any])["messages"] as! [Any]
        return messages.map({Message(response:response, representation: $0)!})
    }
    
}
