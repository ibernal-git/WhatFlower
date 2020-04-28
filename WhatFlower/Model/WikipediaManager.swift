//
//  WikipediaManager.swift
//  WhatFlower
//
//  Created by Imanol Bernal on 27/04/2020.
//  Copyright © 2020 Imanol Bernal. All rights reserved.
//

import UIKit

protocol WikipediaManagerDelegate {
    func didSearchFinished(_ wikipediaManager: WikipediaManager, flower: String)
    func didFinished(_ wikipediaManager: WikipediaManager, flower: FlowerModel)
    func didFailWithError(error: Error)
}

struct WikipediaManager {
    
    var delegate: WikipediaManagerDelegate?
    
    private let searchFlower = "https://en.wikipedia.org/w/api.php?&format=json&action=query&list=search&srwhat=text&srsearch="
    private let urlFlower = "https://en.wikipedia.org/w/api.php?action=query&formatversion=2&prop=extracts|pageimages&pithumbsize=500&exintro=&explaintext=&format=json&titles="

    
    func searchFlower(_ flower: String) {
        
        if let urlString = performURLEncoding(searchFlower + flower) {
            
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, reponse, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                    } else {
                        let decoder = JSONDecoder()
                        do {
                            
                            let decodedData = try decoder.decode(SearchData.self, from: data!)
                            
                            if decodedData.query.search.count > 0 {
                                let flowerName = decodedData.query.search[0].title
                                self.delegate?.didSearchFinished(self, flower: flowerName)
                                
                            } else {
                                self.delegate?.didSearchFinished(self, flower: "-1")
                            }
                            
                        } catch {
                            self.delegate?.didFailWithError(error: error)
                        }
                    }
                }
                task.resume()
            }
            
        }
        
    }

    
    func performRequest(_ flower: String) {
        
        if flower == "-1" {
            let flowerModel = FlowerModel(title: "Not Found", extract: "Not Found Any Description", url: "")
            self.delegate?.didFinished(self, flower: flowerModel)
        } else {
            if let urlString = performURLEncoding(urlFlower + flower) {
                
                if let url = URL(string: urlString) {
                    let session = URLSession(configuration: .default)
                    let task = session.dataTask(with: url) {(data, response, error) in
                        if error != nil {
                            self.delegate?.didFailWithError(error: error!)
                            return
                        }
                        if let safeData = data {
                            if let flowerModel = self.parseJSON(safeData){
                                self.delegate?.didFinished(self, flower: flowerModel)
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func parseJSON(_ wikiData: Data) -> FlowerModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WikiData.self, from: wikiData)
            if decodedData.query.pages.count > 0 {
                
                let title = decodedData.query.pages[0].title
                let extract = decodedData.query.pages[0].extract
                let url = decodedData.query.pages[0].thumbnail.source
                
                let flowerModel = FlowerModel(title: title, extract: extract, url: url)
                
                return flowerModel
            } else {
                return nil
            }
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    func performURLEncoding(_ urlString: String) -> String? {
        
        guard let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("Cannot format the url String")
        }
        return url
    }
    
}
