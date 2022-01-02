//
//  AddMeetupTextViewCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import MaterialComponents
import UIKit
import RxCocoa

public final class AddMeetupTextViewCell: UITableViewCell {
  //MARK: Subjects
  public var title: PublishSubject<String> = PublishSubject()
  private var placeholder: Variable<String> = Variable("")
  
  //MARK: Views
  fileprivate var textView: UITextView!
  
  //MARK: Events
  public var textValue: Observable<String> {
    return textView.rx.text
      .orEmpty
      .asObservable()
      .filter { [unowned self] _ in return self.textView.textColor != .lightGray }
  }
  
  public var didBeginEditing: ControlEvent<Void> {
    return textView.rx.didBeginEditing
  }
  
  public var didEndEditing: ControlEvent<Void> {
    return textView.rx.didEndEditing
  }
  
  //MARK: DisposeBag
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
    prepareTextView()
  }
  
  private func prepareTextView() {
    textView = UITextView()
    textView.delegate = self
    textView.returnKeyType = .done
    textView.font = MDCTypography.body1Font()
    
    contentView.addSubview(textView)
    
    textView.snp.makeConstraints { make in
      make.edges.equalTo(contentView).inset(5)
    }
    
    // create an initial placetext
    textView.textColor = .lightGray
    
    title.asObservable()
      .bind(to: textView.rx.text)
      .disposed(by: disposeBag)
    
    title.asObservable()
      .bind(to: placeholder)
      .disposed(by: disposeBag)
    
    textView.rx.didBeginEditing
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        if this.textView.textColor == .lightGray {
          this.textView.text = nil
          this.textView.textColor = .black
        }
      })
      .disposed(by: disposeBag)
    
    textView.rx.didEndEditing
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        if this.textView.text.isEmpty {
          this.textView.textColor = .lightGray
          this.textView.text = this.placeholder.value
        }
      })
      .disposed(by: disposeBag)
  }
}

extension AddMeetupTextViewCell: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}
