//
//  SelectPlaceViewModel.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/29/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit

class SelectPlaceViewModel {
    
    var navigateBack: NavigationFunc
    
    var didUpdate: ((Void) -> Void)?
    
    var items: [MapPlace] = []
    
    func search(text: String) {
        MapService.fetchPlaces(text)
        .then { items -> Void in
            self.items = items
            self.didUpdate?()
        }
        .error { _ in
            self.items.removeAll()
            self.didUpdate?()
        }
    }
    
    init() {}

}
