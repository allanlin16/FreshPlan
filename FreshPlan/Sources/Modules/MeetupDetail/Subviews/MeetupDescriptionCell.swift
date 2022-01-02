//
//  MeetupDescriptionCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit
import MaterialComponents

public final class MeetupDescriptionCell: UITableViewCell {
  // MARK: PublishSubject
  public var descriptionText: PublishSubject<String> = PublishSubject()
  
  // MARK: Label
  private var descriptionTextView: UITextView!
  
  // MARK: DIspose bag
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
    prepareDescriptionTextView()
  }
  
  private func prepareDescriptionTextView() {
    descriptionTextView = UITextView()
    descriptionTextView.isScrollEnabled = false
    descriptionTextView.isEditable = false
    descriptionTextView.font = MDCTypography.body1Font()
    
    contentView.addSubview(descriptionTextView)
    
    descriptionTextView.snp.makeConstraints { make in
      make.edges.equalTo(contentView)
    }
    
    descriptionText
      .asObservable()
      .bind(to: descriptionTextView.rx.text)
      .disposed(by: disposeBag)
  }
}
