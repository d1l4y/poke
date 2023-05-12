//
//  EvolutionChainTableViewCell.swift
//  onTopPoke
//
//  Created by Vinicius Augusto Dilay de Paula on 10/05/23.
//

import UIKit

class EvolutionChainTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EvolutionChainTableViewCell"

    // MARK: - Properties
    let nameLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let arrowImage =  UIImage(systemName: "arrow.down.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        imageView.image = arrowImage
        return imageView
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    private func setupUI(){
        contentView.addSubview(nameLabel)
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            arrowImageView.widthAnchor.constraint(equalToConstant: 25),
            arrowImageView.heightAnchor.constraint(equalTo: arrowImageView.widthAnchor),
            arrowImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            arrowImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            arrowImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    func setup(name: String, arrowShouldAppear: Bool) {
        nameLabel.text = name
        arrowImageView.isHidden = arrowShouldAppear
    }
}
