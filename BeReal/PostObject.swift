//
//  PostObject.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import ParseSwift
import UIKit

struct Comment: Codable, Hashable {
    var username: String
    var content: String
}

struct ParsePost: ParseObject, Identifiable {
    // Required by ParseObject
    var objectId: String? = nil
    var createdAt: Date? = nil
    var updatedAt: Date? = nil
    var ACL: ParseACL? = nil
    var originalData: Data? = nil

    // Your fields
    var username: String = ""
    var caption: String = ""
    var imageData: Data? = nil
    var comments: [Comment]? = []
    var location: String? = nil
    var postTime: Date? = nil

    // Optional custom initializer
    init(username: String, caption: String, image: UIImage?, location: String?, postTime: Date?) {
        self.username = username
        self.caption = caption
        self.location = location
        self.postTime = postTime
        if let image = image {
            self.imageData = image.jpegData(compressionQuality: 0.8)
        }
    }

    // Default empty initializer (needed for Parse decoding)
    init() {}
}
