//
//  FriendProfileUserCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-09.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents

public class FriendProfileCell: UITableViewCell {
  // MARK: PublishSubject
  public var profileUrl: PublishSubject<String> = PublishSubject()
  public var fullName: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  public var profileImageView: UIImageView!
  public var fullNameLabel: UILabel!
  
  // MARK: DisposeBag
  private let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareProfileImage()
    prepareFullNameLabel()
  }
  
  private func prepareProfileImage() {
    profileImageView = UIImageView()
    profileImageView.contentMode = .scaleAspectFit
    profileImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    profileImageView.clipsToBounds = true
    profileImageView.layer.cornerRadius = 50
    profileImageView.layer.masksToBounds = true
    
    contentView.addSubview(profileImageView)
    
    profileImageView.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
      make.width.equalTo(100)
      make.height.equalTo(100)
    }
    
    profileUrl
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
      .map { urlString -> UIImage? in
        let cache = CacheStore()
        if let image = cache.getImage(key: urlString as NSString) {
          return image
        } else {
          let url = URL(string: urlString)!
          let data = try? Data(contentsOf: url)
          return UIImage(data: data!)
        }
      }
      .filterNil()
      .observeOn(MainScheduler.instance)
      .bind(to: profileImageView.rx.image)
      .disposed(by: disposeBag)
  }
  
  private func prepareFullNameLabel() {
    fullNameLabel = UILabel()
    fullNameLabel.font = MDCTypography.headlineFont()
    fullNameLabel.textColor = .black
    
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
