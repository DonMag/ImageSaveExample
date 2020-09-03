//
//  ViewController.swift
//  ImageSaveExample
//
//  Created by Don Mag on 9/3/20.
//  Copyright © 2020 DonMag. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	let imgViewForVideo = UIImageView()
	let aspectFitImageView = UIImageView()
	let btn = UIButton()
	let thumbLabel = UILabel()
	let origLabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let img = UIImage(named: "bkg2400x1500") else {
			print("Could not load image!!!")
			return
		}
		
		btn.setTitle("Tap to Create Images", for: [])
		var insets = btn.contentEdgeInsets
		insets.left = 12
		insets.right = 12
		btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
		btn.layer.cornerRadius = 6
		btn.setTitleColor(.white, for: .normal)
		btn.setTitleColor(.darkGray, for: .highlighted)
		btn.backgroundColor = .red
		
		thumbLabel.textAlignment = .center
		origLabel.textAlignment = .center
		
		imgViewForVideo.clipsToBounds = true
		imgViewForVideo.contentMode = .scaleAspectFill
		
		aspectFitImageView.clipsToBounds = true
		aspectFitImageView.contentMode = .scaleAspectFit
		aspectFitImageView.backgroundColor = .yellow
		
		imgViewForVideo.image = img
		aspectFitImageView.image = img
		
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .center
		stack.distribution = .fill
		stack.spacing = 12
		stack.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(stack)
		
		[btn, imgViewForVideo, thumbLabel, aspectFitImageView, origLabel].forEach {
			stack.addArrangedSubview($0)
		}
		
		let g = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			
			stack.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			stack.centerYAnchor.constraint(equalTo: g.centerYAnchor),
			
			// "thumbnail view"
			// width 80, height 375:667 ratio (so it has the same ratio as save size)
			imgViewForVideo.widthAnchor.constraint(equalToConstant: 80.0),
			imgViewForVideo.heightAnchor.constraint(equalTo: imgViewForVideo.widthAnchor, multiplier: 667.0 / 375.0),
			
			// aspectFit image view 240x240
			aspectFitImageView.widthAnchor.constraint(equalToConstant: 240.0),
			aspectFitImageView.heightAnchor.constraint(equalTo: aspectFitImageView.widthAnchor, multiplier: 1.0),
			
		])
		
		btn.addTarget(self, action: #selector(self.saveImagesTapped(_:)), for: .touchUpInside)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let nf = NumberFormatter()
		nf.maximumFractionDigits = 3
		
		let vSZ = imgViewForVideo.frame.size
		guard let w1 = nf.string(for: vSZ.width),
			let h1 = nf.string(for: vSZ.height)
			else {
				print("Weird problem with sizes?")
				return
		}
		
		thumbLabel.text = "AspectFill in: " + w1 + " x " + h1 + " view"
		origLabel.text = "AspectFit in 240 x 240 view"

		let vc = UIAlertController(title: "Please Note", message: "This is Example Code only.\n\nIt should not be considered \"Production Ready\"!", preferredStyle: .alert)
		vc.addAction(UIAlertAction(title: "OK", style: .default))
		present(vc, animated: true, completion: nil)

	}

	@objc func saveImagesTapped(_ sender: Any?) -> Void {

		// make sure the image view has a valid image to begin with
		guard let _ = imgViewForVideo.image else {
			print("imgViewForVideo has no image !!!")
			return
		}
		
		var btn: UIButton?
		if let b = sender as? UIButton {
			b.setTitle("Saving Images", for: [])
			b.backgroundColor = .gray
			b.isEnabled = false
			btn = b
		}

		// call this async just so we see the button title change while saving images
		DispatchQueue.main.async {
			self.saveTheImages(btn)
		}

	}
	
	// NOTE: this is example code only
	//	for example, there is no error handling if saving images fails
	func saveTheImages(_ btn: UIButton?) -> Void {
		// make sure the image view has a valid image to begin with
		guard let img = imgViewForVideo.image else {
			print("imgViewForVideo has no image !!!")
			return
		}
		
		let targetSZ = CGSize(width: 375, height: 667)
		
		var newImage: UIImage!
		
		// get a UIImage at target size
		//	uses screenScale, so 375 x 667 target size produces:
		//		on @2x device: 750 x 1334 image
		//		on @3x device: 1125 x 2001 image
		//	from content of AspectFill image view
		//	using UIView extension
		newImage = imgViewForVideo.resizedImage(targetSZ, useScreenScale: true)
		
		// save image to device
		UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
		
		// get a UIImage at target size
		//	uses screenScale, so 375 x 667 target size produces:
		//		on @2x device: 750 x 1334 image
		//		on @3x device: 1125 x 2001 image
		//	from original UIImage
		//	using UIImage extension
		newImage = img.scaleTo(size: targetSZ, mode: .scaleAspectFill, useScreenScale: true)
		
		// save image to device
		UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
		
		// get a UIImage at target size
		//	DO NOT use screenScale, so 375 x 667 target size produces:
		//		375 x 667 image regardless of device
		//	from content of AspectFill image view
		//	using UIView extension
		newImage = imgViewForVideo.resizedImage(targetSZ, useScreenScale: false)
		
		// save image to device
		UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
		
		// get a UIImage at target size
		//	DO NOT use screenScale, so 375 x 667 target size produces:
		//		375 x 667 image regardless of device
		//	from original UIImage
		//	using UIImage extension
		newImage = img.scaleTo(size: targetSZ, mode: .scaleAspectFill, useScreenScale: false)
		
		// save image to device
		UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
		
		btn?.setTitle("Images Saved", for: [])
		btn?.backgroundColor = UIColor.blue
		
	}
	
}

