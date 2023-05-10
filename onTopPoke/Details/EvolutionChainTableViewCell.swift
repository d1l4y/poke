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
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image =  UIImage(systemName: "arrow.down")
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
            arrowImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalTo: arrowImageView.widthAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setup(name: String, arrowShouldAppear: Bool) {
        nameLabel.text = name
        arrowImageView.isHidden = arrowShouldAppear
    }
}
