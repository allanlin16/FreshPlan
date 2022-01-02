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

public final class EditMeetupTextFieldCell: UITableViewCell {
  //MARK: Subjects
  public var label: PublishSubject<String> = PublishSubject()
  public var placeholder: PublishSubject<String> = PublishSubject()
  
  //MARK: Views
  private var titleLabel: UILabel!
  private var textField: UITextField!
  
  //MARK: Events
  public var textValue: ControlProperty<String?> {
    return textField.rx.text
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
    preparetextField()
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
    
    label
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func preparetextField() {
    textField = UITextField()
    textField.delegate = self
    textField.font = MDCTypography.body1Font()
    textField.clearButtonMode = .always
    textField.returnKeyType = .done
    textField.contentMode = .left
    textField.textAlignment = .left
    textField.placeholder = "Meetup Name"
    
    contentView.addSubview(textField)
    
    textField.snp.makeConstraints { make in
      make.top.equalTo(contentView)
      make.bottom.equalTo(contentView)
      make.left.equalTo(titleLabel.snp.right).offset(5)
      make.width.equalTo(contentView).multipliedBy(0.60)
    }
    
    placeholder
      .asObservable()
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
  }
}

extension EditMeetupTextFieldCell: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return false
  }
}

