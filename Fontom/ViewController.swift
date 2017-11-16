//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private let weights: [FontWeight] = [.regular,
                                         .bold,
                                         .medium]

    private var selectedSize: CGFloat = 16 {
        didSet {
            fontSizeLabel.text = String(format: "%.0f", selectedSize)
            updateFonts()
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }

    private var selectedWeight: FontWeight = .regular {
        didSet {
            updateFonts()
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }

    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(test))
        toolBar.setItems([doneItem], animated: false)
        return toolBar
    }()

    // MARK: - Subviews

    lazy var systemFontTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.text = "Sample text"
        textView.textColor = .black
        return textView
    }()

    lazy var applicationFontTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.text = "Sample text"
        textView.textColor = .black
        return textView
    }()

    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.value = Float(selectedSize)
        slider.minimumValue = 0
        slider.maximumValue = 72
        slider.addTarget(self, action: #selector(changeFontSize), for: .valueChanged)
        return slider
    }()

    lazy var fontSizeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = String(format: "%.0f", selectedSize)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()

    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: weights.map { $0.rawValue })
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(changeFontWeight), for: .valueChanged)
        return segmentedControl
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateFonts()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(test))
        view.addGestureRecognizer(recognizer)

        view.addSubview(systemFontTextView)
        view.addSubview(applicationFontTextView)
        view.addSubview(slider)
        view.addSubview(fontSizeLabel)
        view.addSubview(segmentedControl)
    }

    @objc func test() {
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        fontSizeLabel.frame = CGRect(x: view.bounds.width - 40,
                                     y: view.bounds.height - 40,
                                     width: 40,
                                     height: 40)

        slider.frame = CGRect(x: 0,
                              y: view.bounds.height - 40,
                              width: view.bounds.width - fontSizeLabel.bounds.width,
                              height: 40)

        segmentedControl.frame = CGRect(x: 0,
                                        y: view.bounds.height - 80,
                                        width: view.bounds.width,
                                        height: 40)

        let topInset: CGFloat
        if #available(iOS 11, *) {
            topInset = view.safeAreaInsets.top
        }
        else {
            topInset = topLayoutGuide.length
        }

        systemFontTextView.frame = CGRect(x: 0,
                                          y: topInset,
                                          width: view.bounds.width,
                                          height: (view.bounds.height - 80) / 2)

        applicationFontTextView.frame = CGRect(x: 0,
                                               y: systemFontTextView.frame.maxY,
                                               width: view.bounds.width,
                                               height: (view.bounds.height - 80) / 2)
    }

    // MARK: - Actions

    @objc private func changeFontSize() {
        selectedSize = CGFloat(slider.value)
    }

    @objc private func changeFontWeight() {
        selectedWeight = weights[segmentedControl.selectedSegmentIndex]
    }

    // MARK: - Private

    func updateFonts() {
        systemFontTextView.font = .systemFont(ofSize: selectedSize, weight: selectedWeight.weight)
        applicationFontTextView.font = .sfProTextFont(ofSize: selectedSize, weight: selectedWeight)
    }
}

extension ViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolBar
        return true
    }
}
