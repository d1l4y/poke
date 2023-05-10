import UIKit

/// Main view showing the list of Pokémon
///
/// The tableview is setup already. but fetching from a fake request handler, returning fake Pokémon, and showing a local image
/// Goal:
/// - Use your own `RequestHandler` to fetch Pokémon from the backend
/// - Display the pokemon name and image (fetched remotely)
/// - Implement pagination to simulate infinite scrolling
/// - Error handling
///
/// Not required, but feel free to improve/reorganize the ViewController however you like.
class ListViewController: UIViewController {

    var viewModel : ListViewModelProtocol?
    
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
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: "ListCollectionViewCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    required init(viewModel: ListViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "POKÉMON"

        setupViews()
        viewModel?.fetchSpecies()
        viewModel?.didFetchRequest = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentSpecies = viewModel?.getCurrentSpecies(at: indexPath.row) else {
            return
        }
        //TODO: config images
        let viewController = DetailsViewController(species: currentSpecies)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

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
        
        // TODO Fetch the image remotely, based on the Pokémon ID ("list index + 1")
        // TODO This requires `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{species_id}.png`
        cell.setup(text: currentSpecies.name)
        return cell
    }
    
}
