import UIKit

/// Details view showing the evolution chain of a Pokémon (WIP)
///
/// It now only shows a placeholder image, make it so that it also shows the evolution chain of the selected Pokémon, in whatever way you think works best.
/// The evolution chain url can be fetched using the endpoint `APIRouter.getSpecies(URL)` (returns type `SpeciesDetails`), and the evolution chain details through `APIRouter.getEvolutionChain(URL)` (returns type `EvolutionChainDetails`).
/// Requires a working `RequestHandler`
class DetailsViewController: UIViewController {
    var viewModel: DetailsViewModelProtocol?
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(EvolutionChainTableViewCell.self, forCellReuseIdentifier: EvolutionChainTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var headerView: UIView = {
        let headerView = UIView()
        return headerView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Image")
        return imageView
    }()

    //MARK: - Life Cycle
    init(viewModel: DetailsViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.fetchDetails()
        viewModel?.didFetchRequest = { [weak self] in
            guard let self else { return }
            self.reloadData()
        }
        
        setupViews()
        setupUI()
        
    }
    
    //MARK: - Setup
    private func setupViews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 150)
        headerView.addSubview(imageView)

        imageView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width * 0.8, height: headerView.frame.height * 0.8)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    func setupUI() {
        view.backgroundColor = .white
        title = viewModel?.getSpeciesName()
        imageView.image = viewModel?.getSpeciesImage()
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let evolutionChainSize = viewModel?.getChainLinkSize() else { return 0
        }
        return evolutionChainSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EvolutionChainTableViewCell.reuseIdentifier, for: indexPath) as? EvolutionChainTableViewCell,
              let chainLink = viewModel?.getCurrentChain(at: indexPath.row) else { return UITableViewCell() }
        cell.selectionStyle = .none 
        cell.setup(name: chainLink.species.name,
                   arrowShouldAppear: chainLink.evolvesTo.isEmpty)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let headerHeight = headerView.bounds.height
        let alpha = 1 -  offsetY / headerHeight
        headerView.alpha = max(0, alpha)
    }
}

