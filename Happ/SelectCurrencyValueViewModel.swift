//
//  SelectCurrencyValueViewModel.swift
//  Happ
//
//  Created by Aleksei Pugachev on 12/29/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import Foundation
import PromiseKit

class SelectCurrencyValueViewModel {
    
    var navigateBack: NavigationFunc
    
    var didUpdate: ((Void) -> Void)?
    
    var items: [CurrencyModel] = []
    
    init() {
        ProfileService.fetchCurrencies()
            .then { _ -> Void in
                self.items = Array(ProfileService.getCurrenciesStored())
                self.didUpdate?()
        }
    }
    
}
