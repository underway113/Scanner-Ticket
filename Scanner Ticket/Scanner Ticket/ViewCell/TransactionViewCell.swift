//
//  TransactionViewCell.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 04/06/24.
//

import UIKit

class TransactionViewCell: UITableViewCell {

    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let timeLabel = UILabel()
    let iconImageView = UIImageView()
    let detailsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        iconImageView.contentMode = .scaleAspectFit
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.numberOfLines = 0

        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(detailsLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            timeLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            detailsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            detailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            detailsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }

    func configure(with transaction: Transaction) {
        nameLabel.text = transaction.participantName

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        dateLabel.text = dateFormatter.string(from: transaction.timestamp.dateValue())

        dateFormatter.dateFormat = "HH:mm:ss"
        timeLabel.text = dateFormatter.string(from: transaction.timestamp.dateValue())

        var tintColor = UIColor.systemGreen
        var image = UIImage(systemName: "qrcode.viewfinder")
        if transaction.transactionType == "add" {
            tintColor = .systemGreen
            image = UIImage(systemName: "plus.app.fill")
        }
        else if transaction.transactionType == "update" {
            tintColor = .systemBlue
            image = UIImage(systemName: "pencil.circle")
        }

        iconImageView.tintColor = tintColor
        iconImageView.image = image

        let attributedString = NSMutableAttributedString()

        for (key, value) in transaction.transactionDetails {
            let text = NSAttributedString(string: "\(key): ")
            attributedString.append(text)

            let imageAttachment = NSTextAttachment()
            imageAttachment.image = (value as! Int) == 1 ? UIImage.tintedCheckmarkSquareFillImage(color: .white) : UIImage.tintedXSquareImage(color: .white)
            imageAttachment.bounds = CGRect(x: 0, y: -3, width: 14, height: 14)
            let imageString = NSAttributedString(attachment: imageAttachment)
            attributedString.append(imageString)

            let separator = NSAttributedString(string: ", ")
            attributedString.append(separator)
        }

        if attributedString.length > 2 {
            attributedString.deleteCharacters(in: NSRange(location: attributedString.length - 2, length: 2))
        }

        detailsLabel.attributedText = attributedString
    }
}
