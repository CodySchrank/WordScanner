//
//  ViewController.swift
//  WordScanner
//
//  Created by Cody Schrank on 5/6/15.
//  Copyright (c) 2015 TheTapAttack. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import OpenGLES
import QuartzCore

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, G8TesseractDelegate {

    var imagePicker: UIImagePickerController!
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var imagedata = false
    var tesseract = G8Tesseract(language: "eng")
    var theImages:  (UIImage,UIImage)? = nil
    let socket = SocketIOClient(socketURL: "192.168.15.94:3000", options: nil)
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func takeAnotherButtonPressed(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: false, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        let tableView = storyBoard.instantiateViewControllerWithIdentifier("TableView") as? UIViewController
        self.navigationController?.pushViewController(tableView!, animated: true)
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let newRect = CGSize(width: image!.size.width / 3, height: image!.size.height / 3)
        let newImage = RBResizeImage(image!, targetSize: newRect)
        let filter = GPUImageAdaptiveThresholdFilter()
        filter.blurRadiusInPixels = 100.0
        let filteredImage = filter.imageByFilteringImage(newImage)
        tesseract.charWhitelist = "abcdefghijklmnopqrstuvwxyz "
        tesseract.image = filteredImage
        imageView.image = filteredImage
        textLabel.text = tesseract.recognizedText
        imagePicker.dismissViewControllerAnimated(false, completion: nil)
        var text = tesseract.recognizedText
        socket.emit("text", [text])
        imagedata = true
        theImages = (image!,filteredImage)
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func progressImageRecognitionForTesseract(tesseract: G8Tesseract!) {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        imagePicker.view.addSubview(activityView)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imagedata = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tesseract.delegate = self
        socket.connect()
    }
    
    override func viewDidAppear(animated: Bool) {
        //Opens the camera
        if imagedata == false {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

