//
//  ParticipantTableViewCell.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 01/06/24.
//

import UIKit

class ParticipantTableViewCell: UITableViewCell {
    // MARK: - Properties
    private let documentIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "check-white")
        return imageView
    }()

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        addSubview(documentIDLabel)
        addSubview(nameLabel)
        addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            documentIDLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            documentIDLabel.widthAnchor.constraint(equalToConstant: 80),
            documentIDLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: documentIDLabel.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // MARK: - Configure
    func configure(id: String, name: String, value: Bool) {
        documentIDLabel.text = id
        nameLabel.text = name
        
        if value {
            checkmarkImageView.isHidden = false
        } else {
            checkmarkImageView.isHidden = true
        }
    }
}
