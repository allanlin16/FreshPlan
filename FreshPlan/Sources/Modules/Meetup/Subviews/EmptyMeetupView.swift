//
//  EmptyMeetupView.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents

public class EmptyMeetupView: UIView {
  //MARK: StackView
  private var stackView: UIStackView!
  private var titleStackView: UIStackView!
  
  //MARK: Labels
  private var titleImageView: UIImageView!
  private var titleLabel: UILabel!
  private var descriptionLabel: UILabel!
  
  public convenience init() {
    self.init(frame: .zero)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    prepareStackView()
    prepareTitleStackView()
    prepareTitleImageView()
    prepareTitleLabel()
    prepareDescriptionLabel()
  }
  
  private func prepareStackView() {
    stackView = UIStackView()
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 10
    
    addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
  }
  
  private func prepareTitleStackView() {
    titleStackView = UIStackView()
    titleStackView.axis = .horizontal
    titleStackView.spacing = 5
    titleStackView.distribution = .fill
    
    stackView.addArrangedSubview(titleStackView)
  }
  
  private func prepareTitleImageView() {
    titleImageView = UIImageView()
    titleImageView.contentMode = .scaleAspectFit
    titleImageView.image = UIImage(named: "ic_event")?.withRenderingMode(.alwaysTemplate)
    titleImageView.tintColor = .black
    
    titleStackView.addArrangedSubview(titleImageView)
    
    titleImageView.snp.makeConstraints { make in
      make.width.equalTo(30)
      make.height.equalTo(30)
    }
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.body2Font()
    titleLabel.text = "No Meetups"
    
    titleStackView.addArrangedSubview(titleLabel)
  }
  
  private func prepareDescriptionLabel() {
    descriptionLabel = UILabel()
    descriptionLabel.font = MDCTypography.body1Font()
    descriptionLabel.numberOfLines = 2
    descriptionLabel.text = "To add a 'meetup', click the '+' on the top right."
    
    stackView.addArrangedSubview(descriptionLabel)
  }
}
