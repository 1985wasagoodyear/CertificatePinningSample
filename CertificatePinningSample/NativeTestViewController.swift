//
//  NativeTestViewController.swift
//  Created 3/22/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import UIKit
import CommonPinning
import NativePinning

class NativeTestViewController: UIViewController {
    
    // MARK: - Storyboard Outlets
    
    @IBOutlet var pinningOptionSegControl: UISegmentedControl!
    @IBOutlet var actionButton: UIButton! {
        didSet {
            actionButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    // MARK: - Properties
    
    var networker = NetworkManager()
    
    // MARK: - Custom Action Methods
    
    // toggle the current pinning option
    @IBAction func pinningOptionSegControlAction(_ sender: UISegmentedControl) {
        guard let option = PinningOption(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        networker.pinningOption = option
    }
    
    @IBAction func actionButtonAction(_ sender: Any) {
        fetchData()
    }
}

extension NativeTestViewController {
    
    // MARK: - Downloading
    
    func fetchData() {
        networker.download("pikachu") { (result) in
            DispatchQueue.main.async {
                guard let button = self.actionButton else { return }
                switch result {
                    case .success(let mon):
                        self.updateUI(with: mon)
                    case .failure(_):
                        button.setTitle("empty", for: .normal)
                        button.setImage(nil, for: .normal)
                }
            }
        }
    }
    
    func updateUI(with mon: Mon) {
        self.networker.image(from: mon.imageUrl) { (data) in
            guard let button = self.actionButton else { return }
            DispatchQueue.main.async {
                guard let data = data else {
                    button.setTitle("empty", for: .normal)
                    button.setImage(nil, for: .normal)
                    return
                }
                button.setTitle(nil, for: .normal)
                button.setImage(UIImage(data: data), for: .normal)
            }
        }
    }
}
