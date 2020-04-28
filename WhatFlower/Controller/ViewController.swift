//
//  ViewController.swift
//  WhatFlower
//
//  Created by Imanol Bernal on 27/04/2020.
//  Copyright © 2020 Imanol Bernal. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let imagePicker = UIImagePickerController()
    var wikipediaManager = WikipediaManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Press the camera button to take a photo of a flower"
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        wikipediaManager.delegate = self

    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //imageView.image = image
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("Cannot convert image to CIImage")
            }
            
            detect(flowerImage: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(flowerImage: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Cannot import model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            // I keep the first element in classification, not the whole array
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Cannot get results from model")
            }
            
            // the property identifie" is the string of the found object, in this case the flower
            self.navigationItem.title = classification.identifier.capitalized
            self.wikipediaManager.searchFlower(classification.identifier.capitalized)
            
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
}

extension ViewController: WikipediaManagerDelegate {
    func didSearchFinished(_ wikipediaManager: WikipediaManager, flower: String) {
       wikipediaManager.performRequest(flower)
    }
    
    
    func didFinished(_ wikipediaManager: WikipediaManager, flower: FlowerModel) {
        DispatchQueue.main.async {
            self.label.text = flower.extract
            if let url = URL(string: flower.url) {
                self.imageView.load(url: url)
            }
            //flower.url
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
