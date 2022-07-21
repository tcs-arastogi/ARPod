//
//  ARProjectViewController.swift
//  ARDesignerApp
//
//  Created by Yurii Goroshenko on 6/7/22.
//

import UIKit
import ARKit
import SceneKit

final class ARProjectViewController: UIViewController {
    enum Constants {
        static let priceAttribute = TextAttribute(UIFont.brandBoldFont(ofSize: 16), UIColor.black)
        static let titleAttribute = TextAttribute(UIFont.brandFont(ofSize: 16), UIColor.black)
        static let textAttribute = TextAttribute(UIFont.brandFont(ofSize: 14), UIColor.white)
        static let infoAttribute = TextAttribute(UIFont.brandFont(ofSize: 11), UIColor.lightGray)
        static let animationDuration: Double = 0.5
    }
    
    // MARK: - Properties
    private let viewModel: ARProjectViewModelInputProtocol
    private var isSelectedObject: Bool = false
    private var isOnFlash: Bool = false
    private var isLocalAutosortEnabled: Bool = false { didSet { set(sortingButton: isLocalAutosortEnabled) } }
    private let toolTip: ToolTip = ToolTip()
    private lazy var sceneManager: SceneManager = { SceneManager(sceneView, delegate: self) }()
    
    // MARK: - LayoutConstraints
    @IBOutlet private weak var totalPriceRightLayout: NSLayoutConstraint!
    @IBOutlet private weak var measurementsRightLayout: NSLayoutConstraint!
    @IBOutlet private weak var saveRightLayout: NSLayoutConstraint!
    @IBOutlet private weak var sortingRightLayout: NSLayoutConstraint!
    @IBOutlet private weak var dublicateRightLayout: NSLayoutConstraint!
    @IBOutlet private weak var rotateRightLayout: NSLayoutConstraint!
    @IBOutlet private weak var clearLeftLayout: NSLayoutConstraint!
    @IBOutlet private weak var undoLeftLayout: NSLayoutConstraint!
    @IBOutlet private weak var pickerLeftLayout: NSLayoutConstraint!
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sceneView: ARSCNView!
    @IBOutlet private weak var widthTextField: UITextField!
    @IBOutlet private weak var lengthTextField: UITextField!
    @IBOutlet private weak var heightTextField: UITextField!
    @IBOutlet private weak var flashButton: UIButton!
    @IBOutlet private weak var topPanelView: UIView!
    @IBOutlet private weak var saveView: UIView!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var measurementsView: UIView!
    @IBOutlet private weak var centerView: UIView!
    @IBOutlet private weak var sortView: UIView!
    @IBOutlet private weak var dublicateView: UIView!
    @IBOutlet private weak var rotateView: UIView!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var undoButton: UIButton!
    @IBOutlet private weak var undoView: UIView!
    @IBOutlet private weak var bottomPanelView: UIView!
    @IBOutlet private weak var mainButton: UIButton!
    @IBOutlet private weak var activityView: UIView!
    @IBOutlet private weak var activityLabel: UILabel!
    
    // MARK: - Lifecycle
    deinit {
        sceneView.session.pause()
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: ARProjectViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: ARProjectViewModel(project: nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let views: [UIView] = [rotateView, dublicateView, sortView, undoView, clearButton, pickerView, measurementsView]
        visible(views: views, hide: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let views: [UIView] = [rotateView, dublicateView, sortView, undoView, clearButton, pickerView, measurementsView]
        visible(views: views, hide: true)
    }
    
    func addModel(_ model: VirtualObject, by product: Product, setupExistProject: Bool = false) {
        model.initialPosition = product.position?.toVector3
        product.virtualId = model.id.uuidString
        
        sceneManager.actionAddModel(model,
                                    autosort: isLocalAutosortEnabled,
                                    edit: !setupExistProject,
                                    completionHandler: { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                let title = "Cannot insert new model"
                AlertMessageManager.show(sender: self, title: title, messageText: error.errorDescription)
                return
            }
            
            if !setupExistProject {
                self.viewModel.actionAddProduct(product, modelId: model.id.uuidString)
            }
            
            self.refreshUI()
            self.viewModel.actionChangePosition(by: model)
            
            if !setupExistProject {
                self.viewModel.didSaveProjectPressed()
            }
        })
    }
    
    func didSaveProject() {
        animation(views: [saveView], hide: true, animated: true)
    }
    
    func showErrorMessage(_ message: String) {
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Public
extension ARProjectViewController {
    func refreshMeasurements(hasCallback: Bool = true) {
        widthTextField.text = viewModel.project.measurements.widthValue
        lengthTextField.text = viewModel.project.measurements.lengthValue
        heightTextField.text = viewModel.project.measurements.heightValue
        
        guard hasCallback else { return }
        sceneManager.actionUpdateMeasurements(viewModel.project.measurements)
    }
    
    func refreshUI() {
        switch sceneManager.state {
        case .none:
            centerView.isHidden = false
            mainButton.setImage(UIImage(named: "ic-plus"), for: .normal)
            widthTextField.text = "0.00"
            lengthTextField.text = "0.00"
            heightTextField.text = "0.00"
            let hideViews: [UIView] = [rotateView, dublicateView, undoView, clearButton, pickerView, measurementsView, mainButton]
            animation(views: hideViews, hide: true, animated: true)
            
        case .foundPlane:
            animation(views: [mainButton], hide: false, animated: false)
            if viewModel.isNewProject {
                toolTip.showTip(presenter: self, button: mainButton, text: "Add a point")
            } else {
                toolTip.showTip(presenter: self, button: mainButton, text: "Select a point for draw")
            }
            
        case .waitingForLocation:
            break
            
        case .draggingInitialWidth, .draggingInitialLength:
            break
            
        case .draggingInitialHeight:
            centerView.isHidden = false
            mainButton.setImage(UIImage(named: "ic-done"), for: .normal)
            
            let showViews: [UIView] = [clearButton, pickerView, measurementsView]
            animation(views: showViews, hide: false, animated: true)
            toolTip.showTip(presenter: self, button: mainButton, text: "Select To Complete")
            
        case .done:
            centerView.isHidden = true
            mainButton.setImage(UIImage(named: "ic-shop"), for: .normal)
            if let products = viewModel.project.products, !products.isEmpty {
                let showViews: [UIView] = [rotateView, undoView, dublicateView, sortView, totalPriceLabel]
                animation(views: showViews, hide: false, animated: true)
            } else {
                let hideViews: [UIView] = [clearButton, pickerView, totalPriceLabel, dublicateView, sortView, undoView, rotateView]
                animation(views: hideViews, hide: true, animated: true)
            }
        }
        
        totalPriceLabel.attributedText = viewModel.project.price.attribute(Constants.priceAttribute)
            .add(("\n(\(viewModel.project.productList.count) items)").attribute(Constants.infoAttribute))
    }
    
    func refreshUndoButton() {
        let image = isSelectedObject ? UIImage(systemName: "trash") : UIImage(systemName: "arrow.uturn.left")
        undoButton.setImage(image, for: .normal)
    }
}

// MARK: - Private
private extension ARProjectViewController {
    func setupUI() {
        guard viewModel.isNewProject else {
            setupCurrentProject()
            return
        }
        
        setupNewProject()
    }
    
    func setupNewProject() {
        titleLabel.attributedText = viewModel.project.name.attribute(Constants.titleAttribute)
        let views: [UIView] = [saveView, rotateView, dublicateView, sortView, undoView,
                               clearButton, pickerView, measurementsView, totalPriceLabel]
        animation(views: views, hide: true, animated: false)
        
        sceneManager.setupScene()
        activityView.isHidden = true
        isLocalAutosortEnabled = UserDefaults.isAutosortEnabled && viewModel.isNewProject
        refreshUI()
    }
    
    func setupCurrentProject() {
        titleLabel.attributedText = viewModel.project.name.attribute(Constants.titleAttribute)
        let views: [UIView] = [saveView, rotateView, dublicateView, sortView, undoView,
                               clearButton, pickerView, measurementsView, totalPriceLabel]
        animation(views: views, hide: true, animated: false)
        
        var showViews: [UIView] = []
        
        if !viewModel.project.measurements.isEmpty {
            showViews.append(measurementsView)
            refreshMeasurements(hasCallback: false)
            sceneManager.setupExistingScene(measurements: viewModel.project.measurements)
        }
        
        animation(views: showViews, hide: false, animated: false)
        refreshUI()
    }
    
    func set(sortingButton enabled: Bool) {
        let color = enabled ? UIColor.white.withAlphaComponent(0.75) : UIColor.black.withAlphaComponent(0.7)
        sortView.backgroundColor = color
        
        let button = sortView.subviews.compactMap { $0 as? UIButton }.first
        button?.tintColor = enabled ? .black : .white
    }
    
    func visible(views: [UIView], hide: Bool) {
        views.forEach({ $0.isHidden = hide })
    }
    
    // swiftlint:disable cyclomatic_complexity
    func animation(views: [UIView], hide: Bool, animated: Bool) {
        for view in views {
            switch view.tag {
                // Left Buttons
            case undoView.tag:
                undoLeftLayout.constant = hide ? -76.0 : -16.0
                
            case clearButton.tag:
                clearLeftLayout.constant = hide ? -60.0 : 8.0
                
                // Rigth Buttons
            case rotateView.tag:
                rotateRightLayout.constant = hide ? -76.0 : -16.0
                
            case dublicateView.tag:
                sortingRightLayout.constant = hide ? -76.0 : -16.0
                
            case sortView.tag:
                dublicateRightLayout.constant = hide ? -76.0 : -16.0
                
                // Panels
            case pickerView.tag:
                pickerLeftLayout.constant = hide ? -(136.0 + 16) : -16.0
                self.pickerView.reloadAllComponents()
                
            case measurementsView.tag:
                measurementsRightLayout.constant = hide ? -(76.0 + 16) : -16.0
                
            case totalPriceLabel.tag:
                totalPriceRightLayout.constant = hide ? -180.0 : -16.0
                
            case saveView.tag:
                saveRightLayout.constant = hide ? -88.0 : -16.0
                
            case mainButton.tag:
                mainButton.isEnabled = !hide
                
            default:
                break
            }
        }
        
        guard animated else {
            view.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate
extension ARProjectViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: - need find close value in picker
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.textColor = UIColor.lightGray
        guard let text = textField.text else { return }
        let result = text.replacingOccurrences(of: ",", with: ".")
        let value = Float(result) ?? 0
        
        textField.text = String(format: "%.2f", value)
        // TODO: - need find close value in picker
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ARProjectViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension ARProjectViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let isDrawing =
        sceneManager.state == .draggingInitialWidth ||
        sceneManager.state == .draggingInitialLength ||
        sceneManager.state == .draggingInitialHeight
        
        return isDrawing ? 1000 : 0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = MeasurementsUtils.value(for: row)
        
        let step = MeasurementsUtils.shared.isMetric ? 1.0 : 0.125 // ???
        let value = Float(pickerView.selectedRow(inComponent: component)) * Float(step)
        viewModel.didChangeMeasurementsValue(value, state: sceneManager.state)
        refreshMeasurements(hasCallback: false)
        sceneManager.actionUpdateMeasurements(viewModel.project.measurements)
        
        return NSAttributedString(string: title, attributes: [.foregroundColor: UIColor.white])
    }
}

// MARK: - Actions
extension ARProjectViewController {
    @IBAction func actionBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionFlashPressed(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else { return }
        self.isOnFlash = !isOnFlash
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isOnFlash ? .on : .off
            device.unlockForConfiguration()
            flashButton.setImage(UIImage(named: isOnFlash ? "ic-flash-on" : "ic-flash-off"), for: .normal)
        } catch {
            debugPrintLog("lockForConfiguration error: \(error)")
        }
    }
    
    @IBAction func actionMainShotPressed(_ sender: Any) {
        switch sceneManager.state {
        case .done:
            viewModel.didAddProductPressed()
            
        default:
            sceneManager.actionStartDraw()
        }
    }
    
    // Product actions
    @IBAction func actionRotatePressed(_ sender: Any) {
        sceneManager.actionRotate()
        viewModel.didSaveProjectPressed()
    }
    
    @IBAction func actionSortPressed(_ sender: Any) {
        isLocalAutosortEnabled.toggle()
        if isLocalAutosortEnabled {
            sceneManager.actionSortObjects()
        }
    }
    
    @IBAction func actionDublicatePressed(_ sender: Any) {
        guard let products = viewModel.project.products, !products.isEmpty else { return }
        sceneManager.actionDublicate(autosort: isLocalAutosortEnabled)
    }
    
    @IBAction func actionUndoPressed(_ sender: Any) {
        guard let products = viewModel.project.products, !products.isEmpty else { return }
        sceneManager.actionUndo()
    }
    
    // Project actions
    @IBAction func actionSavePressed(_ sender: Any) {
        viewModel.didSaveProjectPressed()
    }
    
    @IBAction func actionClearPressed(_ sender: Any) {
        viewModel.didChangeMeasurements(Measurements(width: 0, length: 0, height: 0))
        sceneManager.actionClearBox()
    }
    
    @IBAction func actionScreenShotPressed(_ sender: Any) {
        guard let image = sceneView.takeScreenshot() else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @IBAction func actionWidthDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let result = text.replacingOccurrences(of: ",", with: ".")
        let value = Float(result) ?? 0
        viewModel.didChangeMeasurementsValue(value, state: .draggingInitialWidth)
        sceneManager.actionUpdateMeasurements(viewModel.project.measurements)
    }
    
    @IBAction func actionLengthDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let result = text.replacingOccurrences(of: ",", with: ".")
        let value = Float(result) ?? 0
        viewModel.didChangeMeasurementsValue(value, state: .draggingInitialLength)
        sceneManager.actionUpdateMeasurements(viewModel.project.measurements)
    }
    
    @IBAction func actionHeightDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let result = text.replacingOccurrences(of: ",", with: ".")
        let value = Float(result) ?? 0
        viewModel.didChangeMeasurementsValue(value, state: .draggingInitialHeight)
        sceneManager.actionUpdateMeasurements(viewModel.project.measurements)
    }
    
    @IBAction func actionTapOnMeasumentsPressed(_ sender: Any) {
        widthTextField.becomeFirstResponder()
    }
    
    @IBAction func actionChangeProfileNamePressed(_ sender: Any) {
        let action: AlertMessageManager.ActionTextCompletionHandler = { [weak self] value in
            guard let self = self else { return }
            guard self.viewModel.trySaveProject(with: value) else {
                AlertMessageManager.show(
                    sender: self,
                    title: "Sorry",
                    messageText: "Project with the same name already exists")
                return
            }
            self.titleLabel.attributedText = value.attribute(Constants.titleAttribute)
        }
        
        let alertTextField = AlertTextField(placeholder: "Project name",
                                            keyboardType: .default,
                                            message: "Please enter project name",
                                            value: titleLabel.text,
                                            action: ("Edit", action))
        AlertMessageManager.showWithTextField(sender: self, alertTextField: alertTextField)
    }
}

// MARK: - SceneManagerDelegate
extension ARProjectViewController: SceneManagerDelegate {
    func sceneManagerDidTapOnScreen() {
        view.endEditing(true)
    }
    
    func sceneManagerDidChangedDrawState(_ state: SceneManager.DrawingState) {
        refreshUI()
        
        if state == .done {
            viewModel.didSaveProjectPressed()
        }
    }
    
    func sceneManagerDidUpdateMeasurements(_ measurements: Measurements) {
        viewModel.project.measurements = measurements
        refreshMeasurements(hasCallback: false)
    }
    
    func sceneManagerDidRotateFinish(_ model: VirtualObject) {
        
    }
    
    func sceneManagerDidDublicateFinish(_ model: VirtualObject) {
        viewModel.actionDublicateProduct(by: model)
        viewModel.actionChangePosition(by: model)
        refreshUI()
    }
    
    func sceneManagerDidUndoFinish(_ model: VirtualObject) {
        viewModel.actionRemoveProduct(by: model)
        refreshUI()
        
        if viewModel.project.productList.isEmpty {
            isSelectedObject = false
        }
        
        refreshUndoButton()
        viewModel.didSaveProjectPressed()
    }
    
    func sceneManagerDidSorted(_ models: [VirtualObject], overlappedModels: [VirtualObject]) {
        models.forEach { model in
            viewModel.actionChangePosition(by: model)
        }
        viewModel.didSaveProjectPressed()
        guard !overlappedModels.isEmpty else { return }
        let message = overlappedModels
            .compactMap { object in
                viewModel.project.products?.first(where: { $0.sku == object.sku })
            }
            .map(\.name)
            .joined(separator: ",\n")
        
        AlertMessageManager.show(sender: self, title: "Cannot organize boxes:", messageText: message)
    }
    
    func sceneManagerDidStartEdit(_ model: VirtualObject) {
        isSelectedObject = true
        isLocalAutosortEnabled = false
        refreshUndoButton()
    }
    
    func sceneManagerDidMove(_ model: VirtualObject) {
        viewModel.actionChangePosition(by: model)
    }
    
    func sceneManagerDidFinishEdit(_ model: VirtualObject) {
        isSelectedObject = false
        refreshUndoButton()
        viewModel.actionChangePosition(by: model)
        viewModel.didSaveProjectPressed()
    }
    
    func sceneManagerDidOpenProjectFinish() {
        guard !viewModel.project.productList.isEmpty else {
            refreshUI()
            return
        }
        
        // Download models
        activityView.isHidden = false
        viewModel.downloadModels(
            loaderHandler: { [weak self] result in
                self?.activityLabel.attributedText = String(format: "%d / %d downloaded", result.current, result.count).attribute(Constants.textAttribute)
            },
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                for item in result {
                    self.addModel(item.model, by: item.product, setupExistProject: true)
                }
                
                // TODO: - TEMP Solution
                // self.actionSortPressed(self)
                
                self.activityView.isHidden = true
                self.refreshUI()
                self.sceneManager.actionSortObjects()
            })
    }
    
    func sceneManagerDidShowError(_ message: String) {
        AlertMessageManager.show(sender: self, messageText: message)
    }
}
