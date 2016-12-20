//
//  Pokemon.swift
//  Pokedex
//
//  Created by Richard Eccles on 12/19/16.
//  Copyright © 2016 Richard Eccles. All rights reserved.
//

import Foundation

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    
    var name: String {
        
        return _name
    }
    
    var pokedexId: Int {
        
        return _pokedexId
    }
    
    //initialize the class
    init(name: String, pokedexId: Int) {
        
        self._name = name
        self._pokedexId = pokedexId
        
    }
    
}
