//
//  AddMeetupTextFieldCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MaterialComponents
import SnapKit

public final class AddMeetupTextFieldCell: UITableViewCell {
  //MARK: Subjects
  public var title: PublishSubject<String> = PublishSubject()
  
  //MARK: Views
  private var titleLabel: UILabel!
  private var titleTextField: UITextField!
  
  //MARK: Events
  public var textValue: ControlProperty<String?> {
    return titleTextField.rx.text
  }
  
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
    prepareTitleLabel()
    prepareTitleTextField()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.boldFont(from: MDCTypography.subheadFont())
    titleLabel.lineBreakMode = .byWordWrapping
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareTitleTextField() {
    titleTextField = UITextField()
    titleTextField.delegate = self
    titleTextField.font = MDCTypography.body1Font()
    titleTextField.clearButtonMode = .always
    titleTextField.returnKeyType = .done
    titleTextField.contentMode = .left
    titleTextField.textAlignment = .left
    titleTextField.placeholder = "Meetup name"
    
    contentView.addSubview(titleTextField)
    
    titleTextField.snp.makeConstraints { make in
      make.top.equalTo(contentView)
      make.bottom.equalTo(contentView)
      make.left.equalTo(titleLabel.snp.right).offset(5)
      make.width.equalTo(contentView).multipliedBy(0.60)
    }
  }
}

extension AddMeetupTextFieldCell: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return false
  }
}
