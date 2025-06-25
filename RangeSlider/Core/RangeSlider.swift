//
//  RangeSlider.swift
//  Practice
//
//  Created by RudreshUppin on 19/06/25.
//

import Foundation
// RangeSlider.swift


import UIKit

class RangeSlider: UIControl {

    // MARK: - Properties
    
    var minimumValue: CGFloat = 0 { didSet { updateLayerFrames() } }
    var maximumValue: CGFloat = 100 { didSet { updateLayerFrames() } }
    var lowerValue: CGFloat = 10 { didSet { updateLayerFrames() } }
    var upperValue: CGFloat = 90 { didSet { updateLayerFrames() } }

    private let trackLayer = CALayer()
    private let trackHighlightLayer = CALayer()
    
    private let lowerThumbImageView = ThumbImageView()
    private let upperThumbImageView = ThumbImageView()
    
    // --- NEW: Tooltip Properties ---
    private let lowerTooltipView = TooltipView()
    private let upperTooltipView = TooltipView()
    private let tooltipSize = CGSize(width: 50, height: 40)
    private let tooltipPadding: CGFloat = 10
    // ---------------------------------
    
    private var previousLocation = CGPoint()

    var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            trackLayer.backgroundColor = trackTintColor.cgColor
        }
    }
    
    var trackHighlightTintColor: UIColor = .orange {
        didSet {
            trackHighlightLayer.backgroundColor = trackHighlightTintColor.cgColor
        }
    }

    private let thumbImage: UIImage = {
        let size = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: size).image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            UIColor.white.setFill()
            path.fill()
            context.cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 2, color: UIColor.black.withAlphaComponent(0.3).cgColor)
            path.lineWidth = 0.5
            UIColor.lightGray.setStroke()
            path.stroke()
        }
    }()

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayersAndViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayersAndViews()
    }
    
    private func setupLayersAndViews() {
        trackLayer.backgroundColor = trackTintColor.cgColor
        layer.addSublayer(trackLayer)

        trackHighlightLayer.backgroundColor = trackHighlightTintColor.cgColor
        layer.addSublayer(trackHighlightLayer)

        lowerThumbImageView.image = thumbImage
        upperThumbImageView.image = thumbImage
        lowerThumbImageView.frame = CGRect(origin: .zero, size: thumbImage.size)
        upperThumbImageView.frame = CGRect(origin: .zero, size: thumbImage.size)
        
        // --- NEW: Tooltip Setup ---
        lowerTooltipView.frame = CGRect(origin: .zero, size: tooltipSize)
        upperTooltipView.frame = CGRect(origin: .zero, size: tooltipSize)
        
        addSubview(lowerTooltipView)
        addSubview(upperTooltipView)
        
        lowerTooltipView.isHidden = false
        upperTooltipView.isHidden = false
        // --------------------------

        addSubview(lowerThumbImageView)
        addSubview(upperThumbImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }

    private func updateLayerFrames() {
        guard bounds.width > 0 else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let trackHeight: CGFloat = 4.0
        
        trackLayer.frame = CGRect(x: 0, y: (bounds.height - trackHeight) / 2, width: bounds.width, height: trackHeight)
        trackLayer.cornerRadius = trackHeight / 2
        
        let lowerThumbCenter = position(for: lowerValue)
        lowerThumbImageView.center = CGPoint(x: lowerThumbCenter, y: bounds.midY)
        
        let upperThumbCenter = position(for: upperValue)
        upperThumbImageView.center = CGPoint(x: upperThumbCenter, y: bounds.midY)
        
        trackHighlightLayer.frame = CGRect(x: lowerThumbCenter, y: trackLayer.frame.minY, width: upperThumbCenter - lowerThumbCenter, height: trackHeight)

        lowerTooltipView.center = CGPoint(
            x: lowerThumbCenter,
            y: lowerThumbImageView.frame.minY - (tooltipSize.height / 2) - tooltipPadding
        )
        lowerTooltipView.text = String(format: "%.0f", lowerValue) // Format value as integer string

        upperTooltipView.center = CGPoint(
            x: upperThumbCenter,
            y: upperThumbImageView.frame.minY - (tooltipSize.height / 2) - tooltipPadding
        )
        upperTooltipView.text = String(format: "%.0f", upperValue)
        // ---------------------------------------------
        
        CATransaction.commit()
    }
    
    private func position(for value: CGFloat) -> CGFloat {
        let range = maximumValue - minimumValue
        guard range > 0 else { return 0 }
        return bounds.width * (value - minimumValue) / range
    }

    // MARK: - Touch Tracking Changes

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if lowerThumbImageView.frame.insetBy(dx: -10, dy: -10).contains(previousLocation) {
            lowerThumbImageView.isHighlighted = true
            // --- NEW: Show lower tooltip ---
            lowerTooltipView.isHidden = false
            // -------------------------------
        } else if upperThumbImageView.frame.insetBy(dx: -10, dy: -10).contains(previousLocation) {
            upperThumbImageView.isHighlighted = true
            // --- NEW: Show upper tooltip ---
            upperTooltipView.isHidden = false
            // -------------------------------
        }
        
        // Bring the active thumb and its tooltip to the front
        if lowerThumbImageView.isHighlighted {
            bringSubviewToFront(lowerThumbImageView)
            bringSubviewToFront(lowerTooltipView)
        } else if upperThumbImageView.isHighlighted {
            bringSubviewToFront(upperThumbImageView)
            bringSubviewToFront(upperTooltipView)
        }
        
        return lowerThumbImageView.isHighlighted || upperThumbImageView.isHighlighted
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        let range = maximumValue - minimumValue
        guard range > 0 else { return true }
        
        let deltaValue = range * deltaLocation / bounds.width
        previousLocation = location
        
        if lowerThumbImageView.isHighlighted {
            lowerValue += deltaValue
            lowerValue = min(max(lowerValue, minimumValue), upperValue)
        } else if upperThumbImageView.isHighlighted {
            upperValue += deltaValue
            upperValue = max(min(upperValue, maximumValue), lowerValue)
        }
        
        // This automatically updates the tooltips via the didSet observers on the value properties
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbImageView.isHighlighted = false
        upperThumbImageView.isHighlighted = false
        
        // --- NEW: Hide both tooltips when touch ends ---
        lowerTooltipView.isHidden = false
        upperTooltipView.isHidden = false
        // ----------------------------------------------
    }
}

// MARK: - Helper Views

private class ThumbImageView: UIImageView {
    override var isHighlighted: Bool {
        didSet {
            let scale: CGFloat = isHighlighted ? 1.2 : 1.0
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}


// --- NEW: The Tooltip View Class ---
private class TooltipView: UIView {
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    private let textLabel = UILabel()
    private let backgroundLayer = CAShapeLayer()
    private let bubbleColor = UIColor.red

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Configure the background layer
        backgroundLayer.fillColor = bubbleColor.cgColor
        layer.addSublayer(backgroundLayer)
        
        // Configure the text label
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 18, weight: .bold)
        textLabel.textAlignment = .center
        addSubview(textLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // The main body of the bubble is shorter to leave room for the tail
        let bubbleHeight = bounds.height * 0.8
        
        // Update the label's frame to be centered in the main body of the bubble
        textLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bubbleHeight)

        // Redraw the bubble shape when the view's bounds change
        backgroundLayer.path = drawBubblePath(in: bounds)
    }
    
    // This function draws the speech bubble path with the tail at the bottom
    private func drawBubblePath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        let cornerRadius: CGFloat = 8.0
        
        // The main bubble is not the full height of the view, to leave space for the tail
        let bubbleRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 0.8)
        let tailWidth: CGFloat = 12.0
        let tailHeight = rect.height - bubbleRect.height

        // Start at the top-left corner
        path.move(to: CGPoint(x: bubbleRect.minX + cornerRadius, y: bubbleRect.minY))
        path.addLine(to: CGPoint(x: bubbleRect.maxX - cornerRadius, y: bubbleRect.minY))
        // Top-right corner
        path.addArc(withCenter: CGPoint(x: bubbleRect.maxX - cornerRadius, y: bubbleRect.minY + cornerRadius), radius: cornerRadius, startAngle: .pi * 1.5, endAngle: .pi * 2, clockwise: true)
        path.addLine(to: CGPoint(x: bubbleRect.maxX, y: bubbleRect.maxY - cornerRadius))
        // Bottom-right corner
        path.addArc(withCenter: CGPoint(x: bubbleRect.maxX - cornerRadius, y: bubbleRect.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        
        // --- Draw the tail ---
        let tailBaseCenterX = bubbleRect.midX
        path.addLine(to: CGPoint(x: tailBaseCenterX + tailWidth / 2, y: bubbleRect.maxY))
        // The tip of the tail
        path.addLine(to: CGPoint(x: tailBaseCenterX, y: bubbleRect.maxY + tailHeight))
        // Back up to the base
        path.addLine(to: CGPoint(x: tailBaseCenterX - tailWidth / 2, y: bubbleRect.maxY))
        // ---------------------
        
        path.addLine(to: CGPoint(x: bubbleRect.minX + cornerRadius, y: bubbleRect.maxY))
        // Bottom-left corner
        path.addArc(withCenter: CGPoint(x: bubbleRect.minX + cornerRadius, y: bubbleRect.maxY - cornerRadius), radius: cornerRadius, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: bubbleRect.minX, y: bubbleRect.minY + cornerRadius))
        // Top-left corner
        path.addArc(withCenter: CGPoint(x: bubbleRect.minX + cornerRadius, y: bubbleRect.minY + cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        
        path.close()
        return path.cgPath
    }
}
