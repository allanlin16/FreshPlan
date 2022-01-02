//
//  RegisterViewController.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-10.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import RxSwift
import MaterialComponents
import SnapKit

public final class RegisterViewController: UIViewController {
  
  private var router: RegisterRouter!
  private var viewModel: RegisterViewModelProtocol!
  
  // MARK: - Stack Views
  private var stackView: UIStackView!
  
  // MARK: - Labels
  private var loginInLabel: UILabel!
  
  // MARK: - TextFields
  private var displayNameField: MDCTextField!
  private var emailField: MDCTextField!
  private var passwordField: MDCTextField!
  private var confirmPasswordField: MDCTextField!
  
  // MARK: - Floating Placeholder Input
  private var displayNameFieldController: MDCTextInputControllerDefault!
  private var emailFieldController: MDCTextInputControllerDefault!
  private var passwordFieldController: MDCTextInputControllerDefault!
  private var passwordConfirmFieldController: MDCTextInputControllerDefault!
  
  // MARK: - Constraints
  private var bottomConstraint: Constraint!
  
  // MARK: - Buttons
  private var signUpButton: MDCRaisedButton!
  
  // MARK: - Dispoable bag
  private let disposeBag = DisposeBag()
  
  public convenience init(viewModel: RegisterViewModel, router: RegisterRouter) {
    self.init(nibName: nil, bundle: nil)
    self.viewModel = viewModel
    self.router = router
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // loads the view
  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  private func prepareView() {
    prepareStackView()
    prepareDisplayName()
    prepareEmail()
    preparePassword()
    prepareConfirmPassword()
    prepareSignUpButton()
    prepareLoginInLabel()
  }
  
  private func prepareStackView() {
    stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 10
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      bottomConstraint = make.centerY.equalTo(view).constraint
      make.centerX.equalTo(view)
    }
  }
  
  private func prepareErrorBinding() {
    viewModel.error
      .asObservable()
      .filterNil()
      .subscribe(onNext: { reason in
        let message = MDCSnackbarMessage()
        message.text = reason
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareLoginInLabel() {
    loginInLabel = UILabel()
    let registerText = "Already have an account? Login In here!"
    let mutableString = NSMutableAttributedString(attributedString: NSAttributedString(string: registerText))
    
    mutableString.addAttribute(
      NSAttributedStringKey.foregroundColor,
      value: MDCPalette.lightBlue.accent700!,
      range: NSRange(location: 24, length: 15)
    )
    
    loginInLabel.attributedText = mutableString
    loginInLabel.font = MDCTypography.subheadFont()
    loginInLabel.isUserInteractionEnabled = true
    
    view.addSubview(loginInLabel)
    
    loginInLabel.snp.makeConstraints { make in
      make.bottom.equalTo(view).inset(20)
      make.centerX.equalTo(view)
    }
    
    loginInLabel.rx
      .tapGesture()
      .when(.recognized)
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        try? this.router.route(from: this, to: RegisterRouter.Routes.login.rawValue, parameters: nil)
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareDisplayName() {
    displayNameField = MDCTextField()
    displayNameField.placeholder = "Display Name"
    displayNameField.autocapitalizationType = .none
    displayNameField.returnKeyType = .next
    displayNameField.autocorrectionType = .no
    
    displayNameFieldController = MDCTextInputControllerDefault(textInput: displayNameField)
    
    stackView.addArrangedSubview(displayNameField)
    
    displayNameField.snp.makeConstraints { make in
      make.width.equalTo(view).inset(20)
    }
    
    displayNameField.rx.text
      .orEmpty
      .bind(to: viewModel.displayName)
      .disposed(by: disposeBag)
    
    viewModel.displayNameHelpText
      .asObservable()
      .bind(to: displayNameFieldController.rx.errorText)
      .disposed(by: disposeBag)
    
    displayNameField.rx.controlEvent(.editingDidEndOnExit)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.emailField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareEmail() {
    emailField = MDCTextField()
    emailField.placeholder = "Email Address"
    emailField.autocapitalizationType = .none
    emailField.keyboardType = .emailAddress
    emailField.returnKeyType = .next
    
    emailFieldController = MDCTextInputControllerDefault(textInput: emailField)
    
    stackView.addArrangedSubview(emailField)
    
    emailField.snp.makeConstraints { make in
      make.width.equalTo(view).inset(20)
    }
    
    emailField.rx.text
      .orEmpty
      .bind(to: viewModel.email)
      .disposed(by: disposeBag)
    
    viewModel.emailHelpText
      .asObservable()
      .bind(to: emailFieldController.rx.errorText)
      .disposed(by: disposeBag)
    
    emailField.rx.controlEvent(.editingDidEndOnExit)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.passwordField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func preparePassword() {
    passwordField = MDCTextField()
    passwordField.placeholder = "Password"
    passwordField.isSecureTextEntry = true
    passwordField.returnKeyType = .next
    
    passwordFieldController = MDCTextInputControllerDefault(textInput: passwordField)
    
    stackView.addArrangedSubview(passwordField)
    
    passwordField.snp.makeConstraints { make in
      make.width.equalTo(view).inset(20)
    }
    
    passwordField.rx.text
      .orEmpty
      .bind(to: viewModel.password)
      .disposed(by: disposeBag)
    
    viewModel.passwordHelpText
      .asObservable()
      .bind(to: passwordFieldController.rx.errorText)
      .disposed(by: disposeBag)
    
    passwordField.rx.controlEvent(.editingDidEndOnExit)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        this.confirmPasswordField.becomeFirstResponder()
      })
      .disposed(by: disposeBag)
  }
  
  private func prepareConfirmPassword() {
    confirmPasswordField = MDCTextField()
    confirmPasswordField.placeholder = "Confirm Password"
    confirmPasswordField.isSecureTextEntry = true
    confirmPasswordField.returnKeyType = .done
    
    passwordConfirmFieldController = MDCTextInputControllerDefault(textInput: confirmPasswordField)
    
    stackView.addArrangedSubview(confirmPasswordField)
    
    confirmPasswordField.rx.controlEvent(.editingDidBegin)
      .asObservable()
      .subscribe(onNext: { [weak self] in
        guard let this = self else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
          this.bottomConstraint.update(offset: -100)
          this.view.layoutIfNeeded()
        })
      })
      .disposed(by: disposeBag)
    
    NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide)
      .asObservable()
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
          this.bottomConstraint.update(offset: 0)
          this.view.layoutIfNeeded()
        })
      })
      .disposed(by: disposeBag)
    
    confirmPasswordField.rx.text
      .orEmpty
      .asObservable()
      .bind(to: viewModel.confirmPassword)
      .disposed(by: disposeBag)
    
    viewModel.confirmPasswordHelpText
      .asObservable()
      .bind(to: passwordConfirmFieldController.rx.errorText)
      .disposed(by: disposeBag)
    
    confirmPasswordField.snp.makeConstraints { make in
      make.width.equalTo(view).inset(20)
    }
  }
  
  private func prepareSignUpButton() {
    // prepare the sign up button here
    signUpButton = MDCRaisedButton()
    signUpButton.setTitle("Sign Up", for: .normal)
    signUpButton.backgroundColor = MDCPalette.lightBlue.tint800
    
    stackView.addArrangedSubview(signUpButton)
    
    signUpButton.snp.makeConstraints { make in
      make.width.equalTo(view).inset(20)
    }
    
    viewModel.signUpEnabled
      .bind(to: signUpButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    viewModel.signUpTap = signUpButton.rx.tap.asObservable()
    viewModel.bindButtons()
    
    viewModel.signUpSuccess
      .asObservable()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        guard let this = self else { return }
        guard let text = this.emailField.text else { return }
        try? this.router.route(from: this, to: RegisterRouter.Routes.verify.rawValue, parameters: ["email": text])
        let message = MDCSnackbarMessage(text: "Successfully signed up! Please check your email to verify your account.")
        MDCSnackbarManager.show(message)
        this.clearTextFields()
      })
      .disposed(by: disposeBag)
    
    viewModel.error
      .asObservable()
      .filterNil()
      .subscribe(onNext: { reason in
        let message = MDCSnackbarMessage(text: reason)
        MDCSnackbarManager.show(message)
      })
      .disposed(by: disposeBag)
  }
  
  fileprivate func clearTextFields() {
    displayNameField.text = ""
    emailField.text = ""
    passwordField.text = ""
    confirmPasswordField.text = ""
  }
}
