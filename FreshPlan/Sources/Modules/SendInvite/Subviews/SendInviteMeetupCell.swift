//
//  SendInviteMeetupCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2018-01-07.
//  Copyright © 2018 St Clair College. All rights reserved.
//

import Foundation
import MaterialComponents
import RxSwift
import SnapKit
import RxCocoa
import UIKit
import Moya
import RxDataSources

public final class SendInviteMeetupCell: UITableViewCell{
  
  // MARK: Publish Subject
  public var placeholder: PublishSubject<String> = PublishSubject()
  public var meetups: Variable<[Meetup]> = Variable([])
  
  // MARK: Label
  private var meetupLabel: UILabel!
  
  // MARK: TextField
  private var textField: UITextField!
  
  // MARK: PickerView
  private var meetupPicker: UIPickerView!
  private var adapter: RxPickerViewStringAdapter<[Meetup]>!
  
  // MARK: Tool Bar
  private var doneButton: UIBarButtonItem!
  private var toolBar: UIToolbar!
  
  // MARK: Bag
  private let disposeBag: DisposeBag = DisposeBag()
  
  private var inkViewController: MDCInkTouchController!
  
  // convenience operators
  public var modelSelected: Observable<Meetup> {
    return meetupPicker.rx.itemSelected
      .asObservable()
      .map { [weak self] (component, row) -> Meetup? in
        return self?.meetups.value[component]
      }
      .filterNil()
  }
  
  // initializer require for tableview cell
  // set the indentifier
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareMeetupLabel()
    prepareTextField()
    prepareMeetupPicker()
    prepareToolBar()
    prepareInkView()
    
    contentView.rx.tapGesture()
      .asObservable()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        this.textField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareMeetupLabel() {
    meetupLabel = UILabel()
    meetupLabel.text = "Meetup"
    meetupLabel.font = MDCTypography.boldFont(from: MDCTypography.subheadFont())
    
    contentView.addSubview(meetupLabel)
    
    meetupLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
  }
  
  private func prepareTextField() {
    textField = UITextField()
    textField.font = MDCTypography.body1Font()
    textField.tintColor = .clear
    textField.textAlignment = .center
    textField.delegate = self
    textField.placeholder = "Click to choose Meetup"
    
    contentView.addSubview(textField)
    
    textField.snp.makeConstraints { make in
      make.left.equalTo(meetupLabel.snp.right)
      make.right.equalTo(contentView).offset(-10)
      make.centerY.equalTo(contentView)
    }
    
    placeholder
      .asObservable()
      .filterEmpty()
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareMeetupPicker() {
    meetupPicker = UIPickerView()
    
    meetups
      .asObservable()
      .bind(to: meetupPicker.rx.itemTitles) { _, item in
        return item.title
      }
      .disposed(by: disposeBag)
    
    meetupPicker.rx.itemSelected
      .asObservable()
      .map { [weak self] (component, row) -> Meetup? in
        return self?.meetups.value[component]
      }
      .filterNil()
      .map { $0.title }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    textField.inputView = meetupPicker
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

  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK: InkViewController
extension SendInviteMeetupCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}

extension SendInviteMeetupCell: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}
