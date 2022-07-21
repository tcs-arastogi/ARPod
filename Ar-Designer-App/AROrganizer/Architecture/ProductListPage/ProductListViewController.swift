//
//  ProductListViewController.swift
//  AROrganizer
//
//  Created by Yurii Goroshenko on 6/10/22.
//

import UIKit

final class ProductListViewController: UIViewController {
    private enum Constants {
        static let cellHeight: Double = 196.0
    }
    
    // MARK: - Properties
    private let closeButton: UIButton = UIButton(type: .custom)
    private let viewModel: ProductListViewModelInputProtocol
    
    // MARK: - Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    deinit {
        debugPrintLog("deinit -> ", self)
    }
    
    init(viewModel: ProductListViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(viewModel: ProductListViewModel(project: Project(name: "")))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.appearance(with: UIColor.systemBackground, shadowColor: UIColor.separator)
    }
    
    func refreshUI() {
        activityIndicator.stopAnimating()
        collectionView.reloadData()
    }
    
    func updateProduct(_ product: Product) {
        guard let index = viewModel.products.firstIndex(where: { $0.modelUrl == product.modelUrl }) else { return }
        viewModel.products[index].downloading = product.downloading
        viewModel.products[index].downloaded = product.downloaded
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func showErrorMessage(_ message: String) {
        AlertMessageManager.show(sender: self, messageText: message)
    }
}

// MARK: - Actions
extension ProductListViewController {
    @IBAction func actionClosePressed(_ sender: Any) {
        viewModel.didFinishFlow()
    }
}

// MARK: - Private
private extension ProductListViewController {
    func setupUI() {
        title = "Products"
        closeButton.setup(type: .close)
        closeButton.addTarget(self, action: #selector(actionClosePressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        collectionView?.registerNib(with: ProductCell.self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ProductListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ProductCell.self, forIndexPath: indexPath)
        cell.setup(with: viewModel.products[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectProduct(viewModel.products[indexPath.row])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3 - 2
        return CGSize(width: width, height: Constants.cellHeight)
    }
}

// MARK: - DrivingScrollViewProvider
extension ProductListViewController: DrivingScrollViewProvider {
    public var drivingScrollView: UIScrollView { collectionView }
}
