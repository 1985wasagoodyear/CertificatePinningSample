//
//  AlamoTestViewController.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import UIKit
import CommonPinning
import AlamoPinning

class AlamoTestViewController: UIViewController {
    
    // MARK: - Storyboard Outlets
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Properties
    
    var networker = AlamoNetworkManager()

    // MARK: - Custom Action Methods
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        fetchData()
    }
}

extension AlamoTestViewController {
    
    // MARK: - Downloading
    
    func fetchData() {
        networker.download("pikachu") { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let mon):
                        self.updateUI(with: mon)
                    case .failure(let error):
                        print(error)
                        self.nameLabel.text = "error"
                        self.imageView.image = nil
                }
            }
        }
    }

    func updateUI(with mon: Mon) {
        self.nameLabel.text = mon.name
        self.networker.image(from: mon.imageUrl) { (data) in
            DispatchQueue.main.async {
                guard let data = data else {
                    self.imageView.image = nil; return
                }
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
}
