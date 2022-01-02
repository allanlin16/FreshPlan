//
//  AddMeetupDateCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import UIKit
import MaterialComponents

public final class EditMeetupDateCell: UITableViewCell {
  //MARK: - Publish Subject
  public var title: PublishSubject<String> = PublishSubject()
  public var dateSubject: PublishSubject<Date> = PublishSubject()
  
  //MARK: - Views
  private var titleLabel: UILabel!
  private var textField: UITextField!
  private var inkViewController: MDCInkTouchController!
  
  //MARK: Tool Bar
  private var doneButton: UIBarButtonItem!
  private var toolBar: UIToolbar!
  private var datePickerView: UIDatePicker!
  
  // MARK: Events
  public var date: ControlProperty<Date> {
    return datePickerView.rx.date
  }
  
  public var beginEditing: ControlEvent<Void> {
    return textField.rx.controlEvent(.editingDidBegin)
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
    prepareTextField()
    prepareToolBar()
    prepareDatePicker()
    prepareInkView()
    
    //TODO: I'm not sure if this is efficient, but it's fine right now
    contentView.rx.tapGesture()
      .asObservable()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.textField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.boldFont(from: MDCTypography.subheadFont())
    
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
  
  private func prepareTextField() {
    textField = UITextField()
    textField.font = MDCTypography.body1Font()
    textField.tintColor = .clear
    textField.textAlignment = .center
    textField.delegate = self
    
    contentView.addSubview(textField)
    
    textField.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right)
      make.right.equalTo(contentView).offset(-10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .map { "Click to enter your \($0.lowercased())" }
      .bind(to: textField.rx.placeholder)
      .disposed(by: disposeBag)
  }
  
  private func prepareToolBar() {
    toolBar = UIToolbar()
    toolBar.barStyle = .default
    toolBar.isTranslucent = true
    toolBar.sizeToFit()
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
    
    doneButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.textField.resignFirstResponder()
      })
      .disposed(by: disposeBag)
    
    
    toolBar.items = [flexibleSpace, doneButton]
    
    textField.inputAccessoryView = toolBar
  }
  
  private func prepareDatePicker() {
    datePickerView = UIDatePicker()
    datePickerView.datePickerMode = .dateAndTime
    
    dateSubject
      .asObservable()
      .bind(to: datePickerView.rx.date)
      .disposed(by: disposeBag)
    
    dateSubject
      .asObservable()
      .map { date -> String? in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
      }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    datePickerView.rx.date
      .asObservable()
      .map { date -> String? in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
      }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    textField.inputView = datePickerView
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK: InkViewController
extension EditMeetupDateCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}

extension EditMeetupDateCell: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}

