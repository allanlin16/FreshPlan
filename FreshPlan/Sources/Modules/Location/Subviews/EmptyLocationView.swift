//
//  EmptyView.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-03.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents

public class EmptyLocationView: UIView {
  
  // MARK: - Text
  private var emptyLabel: UILabel!
  private var descriptionLabel: UILabel!
  private var emptyImage: UIImageView!
  
  // MARK: - StackViews to center
  private var titleVerticalStackView: UIStackView!
  private var titleHorizontalStackView: UIStackView!
  
  public convenience init() {
    self.init(frame: CGRect.zero)
    prepareView()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    backgroundColor = .white
    prepareTitleVerticalStackView()
    prepareTitleHorizontalStackView()
    prepareEmptyImage()
    prepareEmptyLabel()
    prepareDescriptionLabel()
  }
  
  private func prepareTitleVerticalStackView() {
    titleVerticalStackView = UIStackView()
    titleVerticalStackView.axis = .vertical
    titleVerticalStackView.alignment = .center
    titleVerticalStackView.distribution = .fill
    titleVerticalStackView.spacing = 10
    
    addSubview(titleVerticalStackView)
    
    titleVerticalStackView.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
  }
  
  private func prepareTitleHorizontalStackView() {
    titleHorizontalStackView = UIStackView()
    titleHorizontalStackView.axis = .horizontal
    titleHorizontalStackView.spacing = 10
    
    titleVerticalStackView.addArrangedSubview(titleHorizontalStackView)
  }
  
  private func prepareEmptyImage() {
    let image = UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate)
    emptyImage = UIImageView(image: image)
    emptyImage.tintColor = .black
    
    titleHorizontalStackView.addArrangedSubview(emptyImage)
    
    emptyImage.snp.makeConstraints { make in
      make.width.equalTo(30)
      make.height.equalTo(30)
    }
  }
  
  private func prepareEmptyLabel() {
    emptyLabel = UILabel()
    emptyLabel.font = MDCTypography.titleFont()
    emptyLabel.text = "No Location Found!"
    
    titleHorizontalStackView.addArrangedSubview(emptyLabel)
  }
  
  private func prepareDescriptionLabel() {
    descriptionLabel = UILabel()
    descriptionLabel.font = MDCTypography.body1Font()
    descriptionLabel.numberOfLines = 2
    descriptionLabel.text = "Either you did not enter a search or no results found!"
    descriptionLabel.textAlignment = .center
    
    titleVerticalStackView.addArrangedSubview(descriptionLabel)
    
    descriptionLabel.snp.makeConstraints { make in
      make.width.equalTo(250)
    }
  }
}


