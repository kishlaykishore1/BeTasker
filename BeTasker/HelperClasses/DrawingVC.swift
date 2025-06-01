//
//  DrawingVC.swift
//  BeTasker
//
//  Created by kishlay kishore on 17/04/25.
//

import UIKit
import PencilKit

class DrawingVC: UIViewController {
    
    private let canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    private let baseImage: UIImage
    private let imageView = UIImageView()
    private var undoButton: UIButton!
    private var redoButton: UIButton!
    private var onDoneAction: ((UIImage) -> Void)?
    
    init(image: UIImage, onDoneAction: ((UIImage) -> Void)? = nil) {
        self.baseImage = image
        self.onDoneAction = onDoneAction
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorFFFFFF202020
        setupImageAndCanvas()
        setupToolPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color191919, requireShadowLine: false, isTans: true)
        setupNavigationBarWithDrawingControls()
        observeUndoManager()
    }
    
    private func setupImageAndCanvas() {
        imageView.image = baseImage
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        canvasView.frame = view.bounds
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasView.becomeFirstResponder()
        view.addSubview(canvasView)
    }
    
    private func setupToolPicker() {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let _ = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    private func renderFinalImage() -> UIImage? {
        let imageSize = baseImage.size
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = baseImage.scale
        
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: rendererFormat)
        
        return renderer.image { context in
            // Draw the base image full size
            baseImage.draw(in: CGRect(origin: .zero, size: imageSize))
            
            // Calculate the scale and offset applied by UIImageView (.scaleAspectFit)
            let imageViewSize = imageView.bounds.size
            let imageAspect = imageSize.width / imageSize.height
            let viewAspect = imageViewSize.width / imageViewSize.height
            
            var drawRect = CGRect.zero
            if imageAspect > viewAspect {
                // Image is wider than view
                let width = imageViewSize.width
                let height = width / imageAspect
                let yOffset = (imageViewSize.height - height) / 2
                drawRect = CGRect(x: 0, y: yOffset, width: width, height: height)
            } else {
                // Image is taller than view
                let height = imageViewSize.height
                let width = height * imageAspect
                let xOffset = (imageViewSize.width - width) / 2
                drawRect = CGRect(x: xOffset, y: 0, width: width, height: height)
            }
            
            // Map canvas drawing into image coordinate space
            let scaleX = imageSize.width / drawRect.width
            let scaleY = imageSize.height / drawRect.height
            context.cgContext.translateBy(x: -drawRect.origin.x * scaleX,
                                          y: -drawRect.origin.y * scaleY)
            context.cgContext.scaleBy(x: scaleX, y: scaleY)
            
            // Render the drawing
            canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
                .draw(in: canvasView.bounds)
        }
    }


}

// MARK: - Navigation Buttons
extension DrawingVC {
    func setupNavigationBarWithDrawingControls() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Annuler", style: .plain,
                                                           target: self, action: #selector(cancelTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Valider", style: .done,
                                                            target: self, action: #selector(doneTapped))
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .fillEqually
        
        undoButton = UIButton(type: .system)
        undoButton.setImage(UIImage(systemName: "arrow.uturn.left"), for: .normal)
        undoButton.tintColor = .gray
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        
        redoButton = UIButton(type: .system)
        redoButton.setImage(UIImage(systemName: "arrow.uturn.right"), for: .normal)
        redoButton.tintColor = .gray
        redoButton.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
        
        stack.addArrangedSubview(undoButton)
        stack.addArrangedSubview(redoButton)
        
        navigationItem.titleView = stack
    }
    
    
    func observeUndoManager() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(undoManagerDidChange),
                                               name: .NSUndoManagerDidUndoChange,
                                               object: canvasView.undoManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(undoManagerDidChange),
                                               name: .NSUndoManagerDidRedoChange,
                                               object: canvasView.undoManager)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(undoManagerDidChange),
                                               name: .NSUndoManagerWillCloseUndoGroup,
                                               object: canvasView.undoManager)
    }
    
    @objc func undoManagerDidChange() {
        let canUndo = canvasView.undoManager?.canUndo ?? false
        let canRedo = canvasView.undoManager?.canRedo ?? false
        updateUndoRedoButtons(canUndo: canUndo, canRedo: canRedo)
    }
    
    func updateUndoRedoButtons(canUndo: Bool, canRedo: Bool) {
        undoButton.isEnabled = canUndo
        undoButton.tintColor = canUndo ? .label : .gray
        
        redoButton.isEnabled = canRedo
        redoButton.tintColor = canRedo ? .label : .gray
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        if let finalImage = renderFinalImage() {
            onDoneAction?(finalImage)
        }
        dismiss(animated: true)
    }
    
    @objc func undoTapped() {
        canvasView.undoManager?.undo()
    }
    
    @objc func redoTapped() {
        canvasView.undoManager?.redo()
    }
    
}
