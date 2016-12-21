//
//  ViewController.swift
//  Pokedex
//
//  Created by Richard Eccles on 12/19/16.
//  Copyright © 2016 Richard Eccles. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //create an array of Pokemon
    var pokemon = [Pokemon]()
    //new array of pokemon that are filtered
    var filteredPokemon = [Pokemon]()
    //music player variable
    var musicPlayer: AVAudioPlayer!
    //need boolean to check to see if we are in search mode
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        searchBar.delegate = self
        //make the search button to "Return"
        searchBar.returnKeyType = UIReturnKeyType.done
        
        parsePokemonCSV()
        //start playing the audio when the view loads
        initAudio()
        
        
    }
    
    func initAudio() {
        //get path to the audio file
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicPlayer.prepareToPlay()
            //loop continuously
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        }
        catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    //parse pokemon csv data
    func parsePokemonCSV() {
        
        //find the path
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            //loop through the rows and get pokeid and name and add it to the pokemon array.
            for row in rows {
                
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, pokedexId: pokeId)
                pokemon.append(poke)
            }
        }
        catch let err as NSError{
            print(err.debugDescription)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //this helps save memory
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            //get the array of pokemon and start configuring the cells
            let poke: Pokemon!
            
            if inSearchMode{
                //if we are in search mode then get the pokemon from filtered array.
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(poke)
            }
            else{
                //if we are not in search mode then get the pokemon from the original array
                poke = pokemon[indexPath.row]
                cell.configureCell(poke)
            }
            
            return cell
        }
        else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //go to detail screen when we select an item in the collection
        
        var poke: Pokemon!
        
        if inSearchMode {
            //send poke from filtered
            poke = filteredPokemon[indexPath.row]
            
        }
        else{
            //send poke from original
            poke = pokemon[indexPath.row]
        }
        
        performSegue(withIdentifier: "PokemonDetailVC", sender: poke)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //if we are in search mode then get the filtered pokemon count
        if inSearchMode {
            
            return filteredPokemon.count
        }
        else {
        //set the number of cells to the amount of pokemon in the array we got from the csv file
        return pokemon.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    @IBAction func musicBtnPressed(_ sender: UIButton) {
        
        //pause music if pressed
        if musicPlayer.isPlaying {
            
            musicPlayer.pause()
            //make button a little transparent
            sender.alpha = 0.2
        }
        else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //if you hit the return button on keyboard
        view.endEditing(true)
    }
    
    //whenever we make a stroke in the search bar this method gets called
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //check to see if we are in search mode. if we have any text is in the search bar then we are in search mode.
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            collection.reloadData()
            //this gets rid of the keyboard
            view.endEditing(true)
        }
        else{
            inSearchMode = true
            //string that is entered in the search bar
            let lower = searchBar.text!.lowercased()
            //filtered pokemon list is equal to the original pokemon list but filtered
            //$0 is a placeholder for all the pokemon objects in the array
            //getting the name value in lowercase.  and is the search bar text contained in the original name?
            filteredPokemon = pokemon.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
            
        }
        
    }
    
    //this happens before segue occurs and where setup data to be sent between VCs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if we are going to the pokemondetailVC
        if segue.identifier == "PokemonDetailVC" {
            //then create variable to create destinationVC as PokemonDetailVC
            if let detailsVC = segue.destination as? PokemonDetailVC {
                //then create variable of poke as the sender as class of Pokemon
                if let poke = sender as? Pokemon {
                    //sending data to the destination view controller
                    detailsVC.pokemon = poke
                }
            }
        }
    }
    
    

}

