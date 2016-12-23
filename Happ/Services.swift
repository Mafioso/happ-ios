//
//  WebPageService.swift
//  Happ
//
//  Created by MacBook Pro on 12/19/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import RealmSwift
import ObjectMapper
import SwiftyJSON


enum HappWebPages: String {
    case Terms = "/api/v1/terms-of-service/"
    case Privacy = "/api/v1/privacy-policy/"
    case OrganizerRules = "/api/v1/organizer-rules/"
    case FAQ = "/api/v1/faq/"

    func getURL() -> String {
        return Host + self.rawValue
    }
}

func UploadImage(image: UIImage) -> Promise<ImageModel> {
    let url = Host + "/upload/"
    let imageData = UIImageJPEGRepresentation(image, 0.7)!

    return Promise { resolve, reject in
        Alamofire
            .upload(
                .POST, url,
                headers: getRequestHeaders(),
                multipartFormData:  { multipartFormData in
                        multipartFormData.appendBodyPart(data: imageData, name: "files", fileName: "image.jpeg", mimeType: "image/jpeg")
                },
                encodingMemoryThreshold: 10 * 1024 * 1024,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.validate()
                        upload.responseJSON { response in
                            debugPrint(".UploadImage", response)
                            let json = JSON(response.result.value!)
                            let results = json.arrayValue
                            let data = results.first!.dictionaryObject
                            let img = Mapper<ImageModel>().map(data)!
                            resolve(img)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        reject(encodingError)
                    }
            })
    }
}




