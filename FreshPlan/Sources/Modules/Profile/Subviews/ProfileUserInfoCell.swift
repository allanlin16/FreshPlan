//
//  ProfileUserInfoCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-11-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import MaterialComponents
import RxSwift
import SnapKit

public final class ProfileUserInfoCell: UITableViewCell {
	
  //MARK: Publish Subjects
  public var title: PublishSubject<String> = PublishSubject()
  public var info: PublishSubject<String> = PublishSubject()
  
  //MARK: Custom Views
	private var inkTouchController: MDCInkTouchController!
  private var lineView: UIView!
  
  //MARK: Labels
  private var titleLabel: UILabel!
  private var descriptionLabel: UILabel!
  
  public let disposeBag: DisposeBag = DisposeBag()
  
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		prepareView()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func prepareView() {
		// set up the ink here
		selectionStyle = .none
    separatorInset = .zero
    prepareInkView()
    prepareTitleLabel()
    prepareInfoLabel()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.body2Font()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInfoLabel() {
    descriptionLabel = UILabel()
    descriptionLabel.font = MDCTypography.body1Font()
    
    contentView.addSubview(descriptionLabel)
    
    descriptionLabel.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    info
      .asObservable()
      .bind(to: descriptionLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkTouchController = MDCInkTouchController(view: self)
    inkTouchController.delegate = self
    inkTouchController.addInkView()
  }
}

// MARK:  MDCInkTouchControllerDelegate
extension ProfileUserInfoCell: MDCInkTouchControllerDelegate {
	public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
		return true
	}
}
