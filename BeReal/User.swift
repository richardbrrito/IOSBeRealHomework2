//
//  User.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    var emailVerified: Bool?
    
    // Required by `ParseObject`
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Required by `ParseUser`
    var username: String?
    var email: String?
    var password: String?
    var authData: [String: [String: String]?]?
}
