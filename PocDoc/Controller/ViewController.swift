//
//  ViewController.swift
//  PocDoc
//
//  Created by Jason Yu on 6/2/19.
//  Copyright © 2019 Jason Yu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifyLabel: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do{
            let model = try VNCoreMLModel(for: SkinCancerImageClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                self.processClassification(for: request, error: error)
            })
            
            request.imageCropAndScaleOption = .centerCrop   //mlmodel wants a 299 x 299
            return request
        }
        catch{
            fatalError("Model has Failed to load: \(error)")
        }
    }()
    
    func processClassification(for request: VNRequest, error: Error?){
        guard let classification = request.results as? [VNClassificationObservation] else {
            self.classifyLabel.text = "Unable to classify image.\n \(error?.localizedDescription ?? "Error")"
            return
        }
        
        if classification.isEmpty {
            self.classifyLabel.text = "Nothing Recognized.\nPlease try again."
        } else {
            let topClassifications = classification.prefix(4)
            let descriptions = topClassifications.map { classification in
                return String(format: "%.2f", classification.confidence * 100) + "% – " + classification.identifier
            }
            
            self.classifyLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
        }
    }
    
    func updateClassifications(for image: UIImage){
//        classifyLabel.text = "Classifying..."
//
//        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
//            let ciImage = CIImage(image: image) else {
//            print("Something did not process correctly...\nPlease try again.")
//            return
//        }
//
//        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
//        do{
//            //pass in classifcation request
//            try handler.perform([classificationRequest])
//        }catch{
//            print("Failed to perform classification on image: \n\(error.localizedDescription)")
//        }
        
        classifyLabel.text = "Classifying..."
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let ciImage = CIImage(image: image) else {
                print("Something went wrong...\nPlease try again.")
                return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
            try handler.perform([classificationRequest])
        } catch {
            print("Failed to perform classification: \(error.localizedDescription)")
        }
    }

    @IBAction func AlbumButton(_ sender: Any) {
//        let albumPhoto = UIImagePickerController()
//        albumPhoto.delegate = self
//        albumPhoto.sourceType = .photoLibrary
//        present(albumPhoto, animated: true, completion: nil)
        
        presentPhotoPicker(sourceType: .photoLibrary)
        
        let photoSourcePicker = UIAlertController()
        
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(choosePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    @IBAction func CameraButton(_ sender: Any) {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
//        let cameraPhoto = UIImagePickerController()
//        cameraPhoto.delegate = self
//        cameraPhoto.sourceType = .camera
//        present(cameraPhoto, animated: true, completion: nil)
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        
            self.presentPhotoPicker(sourceType: .camera)
        
        
        //photoSourcePicker.addAction(takePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        updateClassifications(for: image)
            
        }
    }
    
    
    
    


