//
//  MeetupNoteCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-24.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SnapKit
import MaterialComponents

public final class MeetupNoteCell: UITableViewCell {
  // MARK: Subjects
  public var note: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var textView: UITextView!
  
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
    textView.font = MDCTypography.body1Font()
    textView.isEditable = false
    textView.isScrollEnabled = false
    
    contentView.addSubview(textView)
    
    textView.snp.makeConstraints { make in
      make.edges.equalTo(contentView)
    }
    
    note
      .asObservable()
      .bind(to: textView.rx.text)
      .disposed(by: disposeBag)
  }
}
