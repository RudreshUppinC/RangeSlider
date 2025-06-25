//
//  ViewController.swift
//  RangeSlider
//
//  Created by RudreshUppin on 25/06/25.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Components
    
    private let salaryRangeSlider: RangeSlider = {
        let slider = RangeSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 50 // Example: 0k to 50k
        slider.lowerValue = 13
        slider.upperValue = 25
        slider.trackHighlightTintColor = .red
        slider.trackTintColor = .systemGray4

        return slider
    }()
    
    private let minSalaryValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let maxSalaryValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSalaryLabels() // Set initial values
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add components to the view
        view.addSubview(salaryRangeSlider)
        view.addSubview(minSalaryValueLabel)
        view.addSubview(maxSalaryValueLabel)
        
        // Setup Auto Layout constraints
        NSLayoutConstraint.activate([
            // Center the slider in the view
            salaryRangeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            salaryRangeSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            salaryRangeSlider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            salaryRangeSlider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            salaryRangeSlider.heightAnchor.constraint(equalToConstant: 30),
            
            minSalaryValueLabel.topAnchor.constraint(equalTo: salaryRangeSlider.bottomAnchor, constant: 12),
            minSalaryValueLabel.leadingAnchor.constraint(equalTo: salaryRangeSlider.leadingAnchor),
            
            maxSalaryValueLabel.topAnchor.constraint(equalTo: salaryRangeSlider.bottomAnchor, constant: 12),
            maxSalaryValueLabel.trailingAnchor.constraint(equalTo: salaryRangeSlider.trailingAnchor)
        ])
        
        salaryRangeSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

    }
    
    // MARK: - Actions
    
    @objc private func sliderValueChanged(_ sender: RangeSlider) {
        updateSalaryLabels()
    }
    
    private func updateSalaryLabels() {
        // Get integer values from the slider
        let lower = Int(salaryRangeSlider.lowerValue)
        let upper = Int(salaryRangeSlider.upperValue)
        
        // Update label text
        minSalaryValueLabel.text = "$\(lower)k"
        maxSalaryValueLabel.text = "$\(upper)k"
    }
}

