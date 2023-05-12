import UIKit

class ListViewController: UIViewController {
    var viewModel : ListViewModelProtocol?
    
    // MARK: - Properties
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom:5, right: 5)
        layout.itemSize =  CGSize(width: view.frame.width * 0.25, height: view.frame.height * 0.2)
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //MARK: - Life Cycle
    required init(viewModel: ListViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupUI()
        
        viewModel?.didFetchRequest = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        viewModel?.showAlert = { [weak self] message in
            guard let self else { return }
            self.showAlert(message: message)
        }
        viewModel?.fetchSpecies()
        
    }
    
    //MARK: - Setup
    private func setupViews() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        title = "POKÉMON"
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewModel?.updateShouldFetch(to: false)
        DispatchQueue.main.async {
            self.present(alertController, animated: true) { [weak self] in
                guard let self else { return }
                self.viewModel?.updateShouldFetch(to: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentSpecies = viewModel?.getCurrentSpecies(at: indexPath.row) else {
            return
        }
        viewModel?.fetchImage(at: indexPath.row) {[weak self] image in
            if let self = self, let image {
                let requestHandler: RequestHandling = RequestHandler()
                let viewModel: DetailsViewModelProtocol = DetailsViewModel(species: currentSpecies,
                                                                           speciesImage: image,
                                                                           requestHandler: requestHandler)
                let viewController = DetailsViewController(viewModel: viewModel)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let speciesList = viewModel?.getSpeciesList() else { return 0 }
        return speciesList.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as? ListCollectionViewCell,
              let currentSpecies = viewModel?.getCurrentSpecies(at: indexPath.row) else {
            return UICollectionViewCell()
        }
        cell.setupText(currentSpecies.name)
        viewModel?.fetchImage(at: indexPath.row) { image in
            if let image {
                cell.setupImage(image)
            }
        }
        
        if let lastElement = viewModel?.getSpeciesList().count, indexPath.row == lastElement - 1 {
            viewModel?.fetchSpecies()
        }
        return cell
    }
    
}
