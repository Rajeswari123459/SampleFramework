//
//  ScannerViewController.swift
//  DocumentScanner
//
//  Created by Xaver Lohmueller on 22.09.17.
//

import UIKit
import AVFoundation

public final class ScannerViewController: UIViewController {

    private var observer: Any?

    public weak var delegate: ScannerViewControllerDelegate?
    public var jitter: CGFloat {
        set { scanner.desiredJitter = newValue }
        get { scanner.desiredJitter }
    }
    public var braceColor: UIColor =  UIColor.red//.red
    public var previewColor: UIColor = .clear {
        didSet {
            detectionLayer.fillColor = previewColor.withAlphaComponent(0.3).cgColor
            detectionLayer.strokeColor = previewColor.withAlphaComponent(0.9).cgColor
        }
    }

    public enum Quality {
        case high, medium, fast
    }
    public var verticalLabel:UILabel?
    var verticalLabelMessage = ""


    public var scanningQuality: Quality = .medium {
        didSet {
            switch scanningQuality {
            case .fast:
                scanner.featuresRequired = 1
            case .medium:
                scanner.featuresRequired = 3
            case .high:
                scanner.featuresRequired = 7
            }
        }
    }

    public var progress: Progress {
        scanner.progress
    }

    public init(sessionPreset: AVCaptureSession.Preset = .photo, config: ScannerConfig = .all , verticalLabelMessage:String ) {
        self.sessionPreset = sessionPreset
        self.verticalLabelMessage = verticalLabelMessage
        super.init(nibName: nil, bundle: nil)
        setupUI(config: config)
        observer = progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.progressBar?.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        }
        edgesForExtendedLayout.remove(.top)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) isn't supported")
    }

    private let sessionPreset: AVCaptureSession.Preset
    @IBOutlet private weak var targetView: UIView!
    @IBOutlet private weak var targetButton: UIView!
    @IBOutlet private weak var torchButton: UIView!
    @IBOutlet private weak var torchIcon: UIImageView!
    @IBOutlet private weak var progressBar: UIProgressView!
    var triggerViewHeight:CGFloat?

    private lazy var scanner: DocumentScanner & TorchPickerViewDelegate = {
        AVDocumentScanner(sessionPreset: sessionPreset, delegate: self)
    }()

    private lazy var detectionLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = previewColor.withAlphaComponent(0.3).cgColor
        layer.strokeColor = previewColor.withAlphaComponent(0.9).cgColor
        layer.lineWidth = 2
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()

    private func setupCameraPreview() {
        
        let cameraView = UIView(frame: view.frame)
        let previewLayer = scanner.previewLayer
        previewLayer.frame = view.bounds
        cameraView.layer.addSublayer(previewLayer)

        view.addSubview(cameraView)

        previewLayer.addSublayer(detectionLayer)
        detectionLayer.frame = view.frame
        detectionLayer.path = nil
    }

    private func setupUI(config: ScannerConfig) {

        var config = config
        // Some devices have no build-in torch
        if !scanner.hasTorch {
            config.remove(.torch)
        }

        if config.contains(.manualCapture) {
            let button = takePhotoButtonView()
            view.addSubview(button)
            view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true


            if #available(iOS 11.0, *) {
                view.safeAreaLayoutGuide
                    .bottomAnchor
                    .constraint(equalTo: button.bottomAnchor, constant: 8)
                    .isActive = true
            } else {
                view.bottomAnchor
                    .constraint(equalTo: button.bottomAnchor, constant: 16)
                    .isActive = true
            }
           

        }


        if config.contains(.targetBraces) {
            let targetBraceButton = makeTargetBraceButton()
            targetButton = targetBraceButton
            view.addSubview(targetBraceButton)

            view.leadingAnchor.constraint(equalTo: targetBraceButton.leadingAnchor, constant: -8).isActive = true

            if #available(iOS 11.0, *) {
                view.safeAreaLayoutGuide
                    .bottomAnchor
                    .constraint(equalTo: targetBraceButton.bottomAnchor, constant: 8)
                    .isActive = true
            } else {
                view.bottomAnchor
                    .constraint(equalTo: targetBraceButton.bottomAnchor, constant: 8)
                    .isActive = true
            }

         //   let braces = TargetBraceView()
            var braces:TargetBraceView!
            
       /*
            if  UIDevice.current.screenType == .iPhones_5_5s_5c_SE{
             //   braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 90, y: 25, width: 180.0, height: 360.0))
            //    braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 90, y: (UIScreen.main.bounds.midY - 180) - 66 , width: 180.0, height: 360.0))
                
                braces = TargetBraceView()
                view.addSubview(braces)
                braces.widthAnchor.constraint(equalToConstant: screenWidth * 0.5).isActive = true
                braces.heightAnchor.constraint(equalToConstant: screenHeight * 0.55).isActive = true
                braces.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                braces.centerYAnchor.constraint(equalTo: self.view.centerYAnchor , constant: -33).isActive = true
                
            } else if getDeviceType() == UIUserInterfaceIdiom.pad {
                braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 135, y: UIScreen.main.bounds.midY - (700.0/1.7), width: 270.0, height: 700.0))
                  //  TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: UIScreen.main.bounds.midY - (400.0/1.25), width: 200.0, height: 400.0))
            }

            else if  UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus{
                braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: UIScreen.main.bounds.midY - (400/1.25), width: 200.0, height: 400.0))
            } else if  UIDevice.current.screenType == .iPhones_6_6s_7_8{
               // braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: UIScreen.main.bounds.midY - (400/1.5), width: 200.0, height: 400.0))
             //   braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: (UIScreen.main.bounds.midY - 200) - (66 + 44), width: 200.0, height: 400.0))
                braces = TargetBraceView()
                view.addSubview(braces)
                braces.widthAnchor.constraint(equalToConstant: 200).isActive = true
                braces.heightAnchor.constraint(equalToConstant: 400).isActive = true
                braces.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                braces.centerYAnchor.constraint(equalTo: self.view.centerYAnchor , constant: -66).isActive = true
            }
            else {
              //  print(appDelegate.window.safeAreaInsets.top)
//                braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: UIScreen.main.bounds.midY - (400.0/1.25), width: 200.0, height: 400.0))
        //        braces = TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: (UIScreen.main.bounds.midY - 200) - (66 + 44), width: 200.0, height: 400.0))
                braces = TargetBraceView()
                view.addSubview(braces)
                braces.widthAnchor.constraint(equalToConstant: screenWidth * 0.5).isActive = true
                braces.heightAnchor.constraint(equalToConstant: screenHeight * 0.55).isActive = true
                braces.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                braces.centerYAnchor.constraint(equalTo: self.view.centerYAnchor , constant: -(triggerViewHeight ?? 0.0 )).isActive = true
            }
 */
            braces = TargetBraceView()
            braces.color = braceColor
            braces.isHidden = true
            braces.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(braces)
            
            if getDeviceType() == UIUserInterfaceIdiom.pad {
                let height1 = screenHeight * 0.55
                braces.widthAnchor.constraint(equalToConstant: height1/2.66666).isActive = true //screenWidth * 0.35 //height1/2.66666
                braces.heightAnchor.constraint(equalToConstant: (screenHeight * 0.55)).isActive = true
                
//                let aspectRatio:CGFloat = 3/8//w/h
//                                braces.widthAnchor.constraint(equalToConstant: screenWidth * aspectRatio).isActive = true //screenWidth * 0.35
//                                braces.heightAnchor.constraint(equalToConstant: (screenHeight * aspectRatio)).isActive = true
                
            }else{

//            braces.widthAnchor.constraint(equalToConstant: screenWidth * 0.55).isActive = true //screenWidth * 0.55
//            braces.heightAnchor.constraint(equalToConstant: screenHeight * 0.55).isActive = true //screenHeight * 0.55
                
  //1
                let height1 = screenHeight * 0.55
                braces.widthAnchor.constraint(equalToConstant: height1/2.1).isActive = true //screenWidth * 0.35
                braces.heightAnchor.constraint(equalToConstant: (screenHeight * 0.55)).isActive = true
    

                
//                let width = screenWidth * 0.5
//                braces.widthAnchor.constraint(equalToConstant: width).isActive = true //screenWidth * 0.35
//                braces.heightAnchor.constraint(equalToConstant: (width / (3/8))).isActive = true
                
                
            }
            braces.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            braces.centerYAnchor.constraint(equalTo: self.view.centerYAnchor , constant: -(triggerViewHeight ?? 0.0 )).isActive = true

       
          
//            view.addSubview(braces)
            
//            NSLayoutConstraint.activate([
//                view.centerXAnchor.constraint(equalTo: braces.centerXAnchor),
//                view.centerYAnchor.constraint(equalTo: braces.centerYAnchor, constant: 50),
//                view.widthAnchor.constraint(equalTo: braces.widthAnchor, multiplier: 1.5),
//                braces.heightAnchor.constraint(equalTo: braces.widthAnchor, multiplier: 1.5)
 //           ])
            targetView = braces
            toggleTargetBraces()
            setUpVerticalLabel()
        }

        if config.contains(.torch) {
            let torch = makeTorchButton()
            torchButton = torch
            view.addSubview(torch)
            view.trailingAnchor.constraint(equalTo: torch.trailingAnchor, constant: 8).isActive = true

            if #available(iOS 11.0, *) {
                view.safeAreaLayoutGuide
                    .bottomAnchor
                    .constraint(equalTo: torch.bottomAnchor, constant: 8)
                    .isActive = true
            } else {
                view.bottomAnchor
                    .constraint(equalTo: torch.bottomAnchor, constant: 8)
                    .isActive = true
            }
        }

        if config.contains(.progressBar) {
            let progressBar = makeProgressBar()
            self.progressBar = progressBar
            view.addSubview(progressBar)
            NSLayoutConstraint.activate([
                progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressBar.topAnchor.constraint(equalTo: view.topAnchor),
                progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupCameraPreview()

        
    }
    public override func viewDidAppear(_ animated: Bool) {
        if verticalLabel?.alpha == 1 {return}
        
     
        verticalLabel?.frame = CGRect(x: targetView.frame.maxX - ((verticalLabel!.bounds.width - verticalLabel!.bounds.height)/2), y: (targetView.frame.minY + (verticalLabel!.bounds.width - verticalLabel!.bounds.height)/2) , width: verticalLabel!.bounds.width, height: verticalLabel!.bounds.height)
        
     
        verticalLabel?.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/2))

        UIView.animate(withDuration: 1, animations: {
            self.verticalLabel?.alpha = 1
            self.view.layoutIfNeeded()
        })

    }
   
    func setUpVerticalLabel(){
        verticalLabel = UILabel()
        verticalLabel = UILabel(frame: CGRect.zero)
        verticalLabel?.text = "Make sure to get a clear, well-lit photo that captures the entire check. A dark, high contrast background may be helpful"

        verticalLabel?.text = "\(verticalLabelMessage) \(verticalLabel?.text ?? "")"
        verticalLabel?.textAlignment = .left
        verticalLabel?.textColor =  UIColor.blue
        verticalLabel?.numberOfLines = 0
       
        verticalLabel?.backgroundColor = .clear  // Set background color to see if label is centered
        verticalLabel?.alpha = 0
        verticalLabel?.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(verticalLabel!)


        
//        verticalLabel?.widthAnchor.constraint(equalToConstant: 250).isActive = true
//        verticalLabel?.heightAnchor.constraint(equalToConstant: 100).isActive = true
      //  verticalLabel?.frame = CGRect(x: targetView.frame.maxX/2, y: -targetView.frame.minY, width: 335, height: 50)
        
     
        
        if getDeviceType() == UIUserInterfaceIdiom.pad {
          //  verticalLabel?.frame =  CGRect(x: targetView.frame.maxX - (( (UIScreen.main.bounds.width/1.8) - 130)/2), y: targetView.frame.minY + (((UIScreen.main.bounds.width/1.8) - 130)/2) , width: UIScreen.main.bounds.width/1.8 , height: 130)
//                CGRect(x: targetView.frame.maxX - (( (UIScreen.main.bounds.width/2.3 ) - 200)/2), y: targetView.frame.minY + (((UIScreen.main.bounds.width/2.3 ) - 200)/2) , width: UIScreen.main.bounds.width/2.3 , height: 200)
            
            let widthConstraint = NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight * 0.55 )
            let heightConstraint = NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200 )
            NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: targetView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: targetView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0).isActive = true

         //   verticalLabel!.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true

            view.addConstraints([ widthConstraint, heightConstraint])
            
        }else{
          //  verticalLabel?.frame = CGRect(x: targetView.frame.maxX - ((360 - 80)/2), y: targetView.frame.minY + ((360 - 80)/2) , width: 360, height: 80)
            let widthConstraint = NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: screenHeight * 0.55 )
            let heightConstraint = NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 80)
            NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: targetView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: verticalLabel!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: targetView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0).isActive = true

         //   verticalLabel!.topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true

            view.addConstraints([ widthConstraint, heightConstraint])
    }
        
            
        

        verticalLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        if  UIDevice.current.screenType == .iPhones_5_5s_5c_SE{
            verticalLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)

        }
        else if getDeviceType() == UIUserInterfaceIdiom.pad {
            verticalLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)

        }
           


     //   TargetBraceView(frame: CGRect(x: UIScreen.main.bounds.midX - 100, y: UIScreen.main.bounds.midY - (400 / 1.25), width: 200.0, height: 400.0))
        
      //  view.addConstraint(NSLayoutConstraint(item: verticalLabel as Any, attribute: .leading, relatedBy: .equal, toItem: targetView , attribute: .trailing, multiplier: 1, constant: 0))
       // view.addConstraint(NSLayoutConstraint(item: verticalLabel as Any, attribute: .top, relatedBy: .equal, toItem: targetView, attribute: .top, multiplier: 1, constant: 0))

//        verticalLabel?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        verticalLabel?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        scanner.start()
        scanner.stop()
        if #available(iOS 13.0, *) {
                    let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor = .white
                    navigationController?.navigationBar.standardAppearance = barAppearance
                    navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        } else {
          //  self.navigationController?.navigationBar.tintColor = .white
                   // Fallback on earlier versions
        }

        
        
    }
 

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.view.subviews
            .first { $0 is TorchPickerView }?
            .removeFromSuperview()

        scanner.stop()
    }
 
}

// Actions
extension ScannerViewController {
    @objc
    func captureScreen(gesture: UIGestureRecognizer) {
        if let trigger = gesture.view as? TriggerView {
            trigger.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                trigger.isHighlighted = false
            }
        }

        let boundingRect: RectangleFeature?

      if let present = (targetView), present.isHidden {
            boundingRect = nil
        } else {
            boundingRect = RectangleFeature(
                topLeft: targetView.frame.origin,
                topRight: targetView.frame.origin + CGPoint(x: targetView.frame.width, y: 0),
                bottomLeft: targetView.frame.origin + CGPoint(x: 0, y: targetView.frame.height),
                bottomRight: targetView.frame.origin + CGPoint(x: targetView.frame.width, y: targetView.frame.height)
            )

            print("Yeswescan camera frame => \(boundingRect)")

        }

        scanner.captureImage(in: boundingRect) { [weak self] image in
            if let scanner = self {
                scanner.scanner.stop()
                self?.delegate?.scanner(scanner, didCaptureImage: image)
            }
        }
    }

    @objc
    func toggleTargetBraces() {
        let newColor: UIColor = targetButton.backgroundColor == .white ? .clear : .white
        targetButton.backgroundColor = newColor
        targetView.isHidden.toggle()
    }

    @objc
    func toggleTorch() {
        setTorchUIOn(lastTorchLevel == 0)
        scanner.toggleTorch()
    }

    private func setTorchUIOn(_ on: Bool) {
        torchButton.backgroundColor = on ? .white : .clear
        if #available(iOS 13.0, *),
            let imageView = torchButton.subviews
                .flatMap(\.subviews)
                .compactMap({ $0 as? UIImageView }).first {

            imageView.image = on
                ? UIImage(systemName: "flashlight.on.fill")
                : UIImage(systemName: "flashlight.off.fill")
        }
    }

    @objc
    func showTorchUI(_ sender: Any) {
        // swiftlint:disable:next force_unwrapping
        let superview = navigationController?.view ?? view!

        guard superview.subviews
            .contains(where: { $0 is TorchPickerView }) == false
            else { return }

        if let forceTap = sender as? ForceTouchGestureRecognizer {
            if forceTap.force < 0.25 && forceTap.state == .ended {
                toggleTorch()
                return
            }

            guard forceTap.force > 0.75 else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        let picker = TorchPickerView(frame: view.frame)
        picker.torchLevel = scanner.lastTorchLevel
        picker.frame.origin.y = torchButton.frame.height
        picker.delegate = self
        superview.addSubview(picker)
        picker.frame.origin.x = view.frame.width
        UIView.animate(withDuration: 0.5) {
            picker.frame.origin.x = self.view.frame.width - picker.frame.width
        }
    }
}

extension ScannerViewController: DocumentScannerDelegate {
    public func didCapture(image: UIImage) {
        if let delegate = delegate {
            scanner.pause()
            delegate.scanner(self, didCaptureImage: image)
        }
    }

    public func didRecognize(feature: RectangleFeature?, in image: CIImage) {
        guard let feature = feature else { detectionLayer.path = nil; return }

        detectionLayer.path = feature.bezierPath.cgPath
    }
}

extension ScannerViewController: TorchPickerViewDelegate {
    var lastTorchLevel: Float { scanner.lastTorchLevel }
    var hasTorch: Bool { scanner.hasTorch }

    func didPickTorchLevel(_ level: Float) {
        guard level != lastTorchLevel else { return }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        setTorchUIOn(level != 0)
        scanner.didPickTorchLevel(level)
    }
}
