//
//  Pokemon.swift
//  Pokedex
//
//  Created by Richard Eccles on 12/19/16.
//  Copyright © 2016 Richard Eccles. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionName: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLevel: String!
    
    
    private var _pokemonURL: String!
    
    
    //set getters, we want to protect the data and make sure we are only providing an actual value, if there isnt anything in there, return an empty string
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLevel: String {
        if _nextEvolutionLevel == nil {
            _nextEvolutionLevel = ""
        }
        return _nextEvolutionLevel
    }
    
    var nextEvolutionName: String {
        if _nextEvolutionName == nil {
            _nextEvolutionName = ""
        }
        return _nextEvolutionName
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        
      
        return _attack
    }
    var nextEvolutionTxt: String {
        
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        
        return _nextEvolutionTxt
    }
    
    
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
        
        //create the api url
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
    }
    
    //closure is the variable
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        //alamofire get request
        //make sure you go into info.plst and add app transport security.
        Alamofire.request(_pokemonURL).responseJSON { (response) in
            //put response in a dictionary
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                //get weight from the response and put it in weight variable
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                //get weight from the response
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                //get types out of the array of dictionaries types and make sure there is at least one type
                if let types = dict["types"] as? [Dictionary<String, String>], types.count > 0 {
                    //getting the name out of types array in the first index.
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }
                    
                    //if there is more than one type
                    if types.count > 1 {
                        //loop through all of the types and append the name to the _type variable
                        for x in 1..<types.count {
                            
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                }
                else{
                    self._type = ""
                }
                //get the description information
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>], descArr.count > 0 {
                    //the description we need is in another api
                    if let url = descArr[0]["resource_uri"] {
                        
                        let descURL = "\(URL_BASE)\(url)"
                        
                        Alamofire.request(descURL).responseJSON(completionHandler: { (response) in
                            if let descDict = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let description = descDict["description"] as? String {
                                    
                                    let newDescription = description.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    
                                    self._description = newDescription
                                }
                            }
                            //set our other api as completed
                            completed()
                        })
                    }
                }
                else{
                    self._description = ""
                }
                
                //get the next evolution
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    
                    if let nextEvo = evolutions[0]["to"] as? String {
                        //we only want to keep going if the evo is not a mega since we are not suporting mega pokemon
                        if nextEvo.range(of: "mega") == nil {
                            
                            self._nextEvolutionName = nextEvo
                            //extract pokedex id from url
                            
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                //remove all of the extra url to get the pokeid
                                let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                let nextEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                
                                self._nextEvolutionId = nextEvoId
                                
                                if let lvlExist = evolutions[0]["level"] {
                                    
                                    if let lvl = lvlExist as? Int {
                                        self._nextEvolutionLevel = "\(lvl)"
                                    }
                                }
                                else{
                                    self._nextEvolutionLevel = ""
                                }
                            }
                        }
                    }
                }
                
            }
            //tell the view controller that we have completed the download
            completed()
        }
        
    }
    
}
