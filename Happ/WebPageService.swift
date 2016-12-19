//
//  WebPageService.swift
//  Happ
//
//  Created by MacBook Pro on 12/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation


enum HappWebPages: String {
    case Terms = "/api/v1/terms-of-service/"
    case Privacy = "/api/v1/privacy-policy/"
    case OrganizerRules = "/api/v1/organizer-rules/"

    func getURL() -> String {
        return Host + self.rawValue
    }
}

