//
//  FirstVC.swift
//  FTDRefactor
//
//  Created by Jon E on 8/18/20.
//  Copyright © 2020 Jon E. All rights reserved.
//

import UIKit

class FirstVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var logo = UIImageView()
    var takePicButton = FTDButton(text: "Take Photo")
    var photoLibraryButton = FTDButton(text: "Photo Library")
    var infoButton = UIButton()
    let resultScreen = ResultVC()
    let scanImageScreen = ScanImageVC()
    let infoText = """
    - Make sure the tweet text, username, and date are all shown \n
    - Use good lighting \n
    - Take pictures as close as possible \n

    """

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "myColors")
        configureLogo()
        configurePicButton()
        configurePhotoLibraryButton()
        configureInfoButton()
    }
    
    
    func configureLogo() {
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "detective1")
        logo.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 80),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.heightAnchor.constraint(equalToConstant: 260),
            logo.widthAnchor.constraint(equalToConstant: 260)
        ])
    }
    
    
    func configurePicButton() {
        view.addSubview(takePicButton)
        NSLayoutConstraint.activate([
            takePicButton.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 60),
            takePicButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePicButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.9),
            takePicButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        takePicButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
    }
    
    
    func configurePhotoLibraryButton() {
        view.addSubview(photoLibraryButton)
        NSLayoutConstraint.activate([
            photoLibraryButton.topAnchor.constraint(equalTo: takePicButton.bottomAnchor, constant: 40),
            photoLibraryButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            photoLibraryButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.9),
            photoLibraryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        photoLibraryButton.addTarget(self, action: #selector(getCameraRoll), for: .touchUpInside)
    }
    
    
    @objc func takePicture(_ sender: FTDButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @objc func getCameraRoll(_ sender: FTDButton) {
        let picker = UIImagePickerController()
        //allow the user to edit the size of the image
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    
    func configureInfoButton() {
        view.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .medium)), for: .normal)
        
        NSLayoutConstraint.activate([
            infoButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            infoButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            infoButton.heightAnchor.constraint(equalToConstant: 40),
            infoButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        infoButton.addTarget(self, action: #selector(displayInfo), for: .touchUpInside)
    }
    
    
    @objc func displayInfo() {
        presentGFAlertOnMainThread(title: "Scanning Tips", message: infoText, buttonTitle: "Continue")
    }

    
    @objc func presentGFAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = InfoAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.acButton.addTarget(self, action: #selector(self.dismissVC), for: .touchUpInside)
            self.present(alertVC, animated: true)

        }
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}


extension FirstVC {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        scanImageScreen.image = image
        scanImageScreen.modalPresentationStyle = .fullScreen
        present(scanImageScreen, animated: true)
    }
}
