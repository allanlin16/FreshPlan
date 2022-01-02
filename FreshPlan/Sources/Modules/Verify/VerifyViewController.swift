//
//  VerifyViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import RxSwift
import MaterialComponents

public final class VerifyViewController: UIViewController {
	private var router: VerifyRouter!
	private var viewModel: VerifyViewModelProtocol!
	
	private let disposeBag = DisposeBag()
	
	fileprivate let appBar = MDCAppBar()
	
	// MARK:  StackView
	private var stackView: UIStackView!
	
	// MARK:  Text Fields
	private var verifyTextField: UITextField!
	
	// MARK:  Button
	private var submitButton: MDCButton!
	
	// MARK:  Left Button Item
	private var closeButton: UIBarButtonItem!
	
	public convenience init(viewModel: VerifyViewModel, router: VerifyRouter) {
		self.init(nibName: nil, bundle: nil)
		self.viewModel = viewModel
		self.router = router
		
		self.addChildViewController(appBar.headerViewController)
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		// prepare views here
		prepareView()
	}
	
	public override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	fileprivate func prepareView() {
		view.backgroundColor = .blueBackgroundColor
		prepareStackView()
		prepareVerifyTextField()
		prepareSubmitButton()
		prepareDismissKeyboard()
		prepareErrorSnackBar()
		prepareAppBar()
	}
	
	// MARK : Preparing Views and Bindings
	
	fileprivate func prepareAppBar() {
		appBar.addSubviewsToParent()
		appBar.navigationBar.backgroundColor = .blueBackgroundColor
		appBar.headerViewController.headerView.backgroundColor = .blueBackgroundColor
		
		closeButton = UIBarButtonItem(
			image: UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate),
			style: .plain,
			target: nil,
			action: nil
		)
		
		closeButton.tintColor = .white
		
		closeButton.rx.tap
			.asObservable()
			.subscribe(onNext: { [weak self] in
				guard let this = self else { return }
				this.dismiss(animated: true, completion: nil)
			})
			.disposed(by: disposeBag)
		
		appBar.navigationBar.leftBarButtonItem = closeButton
		
		let mutator = MDCNavigationBarTextColorAccessibilityMutator()
		mutator.mutate(appBar.navigationBar)
	}
	
	fileprivate func prepareErrorSnackBar() {
		viewModel.error
			.asObservable()
			.filterEmpty()
			.subscribe(onNext: { [weak self] reason in
				guard let this = self else { return }
				if this.verifyTextField.becomeFirstResponder() { this.verifyTextField.resignFirstResponder() }
				// create snackbar
        let message = MDCSnackbarMessage()
        let action = MDCSnackbarMessageAction()
        action.handler = {
          this.viewModel.resendCode.on(.next(()))
        }
        action.title = "Resend"
        message.action = action
        message.text = reason
        MDCSnackbarManager.show(message)
			})
			.disposed(by: disposeBag)
	}
	
	fileprivate func prepareDismissKeyboard() {
		view.rx.tapGesture()
			.when(.recognized)
			.asObservable()
			.subscribe(onNext: { [weak self] _ in
				guard let this = self else { return }
				this.verifyTextField.resignFirstResponder()
			})
			.disposed(by: disposeBag)
	}
	
	fileprivate func prepareStackView() {
		stackView = UIStackView()
		stackView.alignment = .center
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.spacing = 10
		
		view.addSubview(stackView)
		
		stackView.snp.makeConstraints { make in
			make.center.equalTo(view)
		}
	}
	
	fileprivate func prepareVerifyTextField() {
		verifyTextField = UITextField()
		verifyTextField.borderStyle = .roundedRect
		verifyTextField.keyboardType = .numberPad
		verifyTextField.returnKeyType = .done
		verifyTextField.font = MDCTypography.headlineFont()
		verifyTextField.placeholder = "Verification Code"
		verifyTextField.textAlignment = .center
		
		stackView.addArrangedSubview(verifyTextField)
		
		verifyTextField.snp.makeConstraints { make in
			make.width.equalTo(350)
			make.height.equalTo(60)
		}
		
		verifyTextField.rx.text
			.orEmpty
			.map { Int($0) }
			.bind(to: viewModel.verificationCode)
			.disposed(by: disposeBag)
	}
	
	fileprivate func prepareSubmitButton() {
		submitButton = MDCButton()
		submitButton.setTitle("Submit", for: .normal)
		submitButton.backgroundColor = .greenBackgroundColor
	
		stackView.addArrangedSubview(submitButton)
		
		submitButton.snp.makeConstraints { make in
			make.width.equalTo(350)
			make.height.equalTo(60)
		}
		
		viewModel.submitTap = submitButton.rx.tap.asObservable()
		viewModel.bindButton()
    
    viewModel.verificationCode
      .asObservable()
      .map { $0 != nil }
      .bind(to: submitButton.rx.isEnabled)
      .disposed(by: disposeBag)
		
		viewModel.submitSuccess
			.asObservable()
			.filter { $0 }
			.subscribe(onNext: { [weak self] _ in
				guard let this = self else { return }
        this.dismiss(animated: true) {
          let message = MDCSnackbarMessage(text: "Account Verified! You can now login.")
          MDCSnackbarManager.show(message)
        }
			})
			.disposed(by: disposeBag)
    
    viewModel.resendSuccess
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { _ in
        let message = MDCSnackbarMessage(text: "Resent a verification email! Please check your email address to verify your account.")
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
	}
}
