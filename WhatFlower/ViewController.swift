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
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
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
            
            
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
}

