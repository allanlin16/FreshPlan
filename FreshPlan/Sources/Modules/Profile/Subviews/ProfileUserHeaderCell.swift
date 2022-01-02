//
//  ProfileUserHeaderCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import MaterialComponents
import SnapKit

public final class ProfileUserHeaderCell: UITableViewCell {
	// MARK:  Publish Subjects
	public var fullName: PublishSubject<String> = PublishSubject()
	public var profileURL: PublishSubject<String> = PublishSubject()
	
	// MARK:  DisposeBag
	private let disposeBag: DisposeBag = DisposeBag()
	
	// MARK:  Views
	private var activityIndicator: UIActivityIndicatorView!
	private var profileImageView: UIImageView!
	private var fullNameLabel: UILabel!
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		prepareView()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func prepareView() {
		selectionStyle = .none
		prepareActivityIndicator()
		prepareProfileImage()
		prepareFullNameLabel()
	}
	
	private func prepareActivityIndicator() {
		activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		activityIndicator.clipsToBounds = true
    activityIndicator.startAnimating()
		
		contentView.addSubview(activityIndicator)
		
		activityIndicator.snp.makeConstraints { make in
      make.width.equalTo(50)
      make.height.equalTo(50)
      make.centerY.equalTo(contentView)
      make.left.equalTo(contentView).offset(10)
		}
	}
	
	private func prepareProfileImage() {
		profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		profileImageView.isHidden = true
		profileImageView.contentMode = .scaleAspectFit
		profileImageView.layer.cornerRadius = 25
		profileImageView.layer.masksToBounds = true
    profileImageView.clipsToBounds = true
		
		contentView.addSubview(profileImageView)
		
		profileImageView.snp.makeConstraints { make in
      make.width.equalTo(50)
      make.height.equalTo(50)
      make.centerY.equalTo(contentView)
      make.left.equalTo(contentView).offset(10)
    }
		
		// set up bindings
		profileURL
			.asObservable()
			.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.map { urlString -> UIImage? in
				let cache = CacheStore()
				if let image = cache.getImage(key: urlString as NSString) {
					return image
				} else {
					let url = URL(string: urlString)
					let data = try? Data(contentsOf: url!)
          return UIImage(data: data!)
				}
			}
      .catchErrorJustComplete()
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] image in
				guard let this = self else { return }
				this.activityIndicator.stopAnimating()
				this.activityIndicator.isHidden = true
				this.profileImageView.isHidden = false
				this.profileImageView.image = image
			})
			.disposed(by: disposeBag)
	}
	
	private func prepareFullNameLabel() {
		fullNameLabel = UILabel()
		fullNameLabel.font = MDCTypography.headlineFont()
		
		contentView.addSubview(fullNameLabel)
		
		fullNameLabel.snp.makeConstraints { make in
			make.left.equalTo(profileImageView.snp.right).offset(10)
			make.centerY.equalTo(contentView)
		}
		
		fullName
			.asObservable()
			.bind(to: fullNameLabel.rx.text)
			.disposed(by: disposeBag)
	}
}
