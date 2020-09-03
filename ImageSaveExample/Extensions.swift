//
//  Extensions.swift
//  ImageSaveExample
//
//  Created by Don Mag on 9/3/20.
//  Copyright © 2020 DonMag. All rights reserved.
//

import UIKit

extension UIView {
	
	// this method will work, but uses multiple image scaling operations
	// resulting in loss of image quality
	
	func resizedImage(_ size: CGSize, useScreenScale: Bool? = true) -> UIImage {
		let format = UIGraphicsImageRendererFormat()
		if useScreenScale == false {
			format.scale = 1
		}
		// use bounds of self
		var renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
		let img = renderer.image { rendererContext in
			layer.render(in: rendererContext.cgContext)
		}
		// use target size
		renderer = UIGraphicsImageRenderer(size: size, format: format)
		return renderer.image { (context) in
			img.draw(in: CGRect(origin: .zero, size: size))
		}
	}
	
}

extension UIImage {
	
	// scales and clips original image
	// optionally preserving aspect ratio
	
	func scaleTo(size targetSize: CGSize, mode: UIView.ContentMode? = .scaleToFill, useScreenScale: Bool? = true) -> UIImage {
		// make sure a valid scale mode was requested
		//	if not, set it to scaleToFill
		var sMode: UIView.ContentMode = mode ?? .scaleToFill
		let validModes: [UIView.ContentMode] = [.scaleToFill, .scaleAspectFit, .scaleAspectFill]
		if !validModes.contains(sMode) {
			print("Invalid contentMode requested - using scaleToFill")
			sMode = .scaleToFill
		}
		
		var scaledImageSize = targetSize
		
		// if scaleToFill, don't maintain aspect ratio
		if mode != .scaleToFill {
			// Determine the scale factor that preserves aspect ratio
			let widthRatio = targetSize.width / size.width
			let heightRatio = targetSize.height / size.height
			
			// scaleAspectFit
			var scaleFactor = min(widthRatio, heightRatio)
			if mode == .scaleAspectFill {
				// scaleAspectFill
				scaleFactor = max(widthRatio, heightRatio)
			}
			
			// Compute the new image size that preserves aspect ratio
			scaledImageSize = CGSize(
				width: size.width * scaleFactor,
				height: size.height * scaleFactor
			)
		}
		
		// UIGraphicsImageRenderer uses screen scale, so...
		//	if targetSize is 100x100
		//		on an iPhone 8, for example, screen scale is 2
		//			renderer will produce a 750 x 1334 image
		//		on an iPhone 11 Pro, for example, screen scale is 3
		//			renderer will produce a 1125 x 2001 image
		//
		// if we want a pixel-exact image, set format.scale = 1
		let format = UIGraphicsImageRendererFormat()
		if useScreenScale == false {
			format.scale = 1
		}
		
		let renderer = UIGraphicsImageRenderer(
			size: targetSize,
			format: format
		)
		var origin = CGPoint.zero
		if mode != .scaleToFill {
			origin.x = (targetSize.width - scaledImageSize.width) * 0.5
			origin.y = (targetSize.height - scaledImageSize.height) * 0.5
		}
		let scaledImage = renderer.image { _ in
			self.draw(in: CGRect(
				origin: origin,
				size: scaledImageSize
			))
		}
		
		return scaledImage
	}
}
