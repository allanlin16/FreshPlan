//
//  EmptyView.swift
//  FreshPlan
//
//  Created by Allan Lin on 2017-12-17.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MaterialComponents

public class EmptyInvitationView: UIView {

  // MARK: - Labels
  private var titleLabel: UILabel!
  private var descriptionLabel: UILabel!
  
  // MARK: - ImageView
  private var titleImageView: UIImageView!
  
  // MARK: - StackViews
  private var stackView: UIStackView!
  private var titleStackView: UIStackView!
  
  // initializer
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

  // prepare all your views
  private func prepareView() {
    prepareStackView()
    prepareTitleStackView()
    prepareTitleImageView()
    prepareTitleLabel()
    prepareDescriptionLabel()
  }
  
  // create the stack view
  private func prepareStackView() {
    stackView = UIStackView()
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 10
    
    addSubview(stackView)
    
    // center stack view
    stackView.snp.makeConstraints { (make) in
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
    titleImageView.image = UIImage(named: "ic_mail")?.withRenderingMode(.alwaysTemplate)
    titleImageView.tintColor = .black
    
    titleStackView.addArrangedSubview(titleImageView)
    
    titleImageView.snp.makeConstraints { (make) in
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.body2Font()
    titleLabel.text = "No Invitations"
    
    titleStackView.addArrangedSubview(titleLabel)
  }
  
  private func prepareDescriptionLabel() {
    descriptionLabel = UILabel()
    descriptionLabel.font = MDCTypography.body2Font()
    descriptionLabel.numberOfLines = 2
    descriptionLabel.text = "There's no Invitations, Start a MeetUp."
    
    stackView.addArrangedSubview(descriptionLabel)
  
  }
  
}

