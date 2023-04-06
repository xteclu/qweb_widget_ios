//
//  QWebWidgetViewController.swift
//  KenesWidget
//
//  Created by Nurken Tileubergenov on 21.10.2022.
//

import UIKit
import WebKit
import SafariServices


open class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, SFSafariViewControllerDelegate {
  let settings: Settings
  
  @available(iOS 15.0, *)
  public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
    print("ASKING FOR")
    print(type.rawValue)
    decisionHandler(.prompt)
  }
  
  public init(settings: Settings) {
    self.settings = settings
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  public func reloadPage() {
    webView?.reload()
  }
  
  public func clearCache(completionHandler: @escaping () -> Void) {
    WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: completionHandler)
  }

  func dev(_ handler: ()->Void) {
    guard settings.loggingEnabled == true else {return}
    handler()
  }
  
  func generateUrl() -> URL? {
    var params: [String] = []
//    if let language = settings.language {
    params.append("lang=\(settings.language.rawValue)")
//    }
    if let topic = settings.call?.topic {
      params.append("topic=\(topic)")
    }
    if settings.mobileRequired ?? false {
      params.append("is_mobile=True")
    }
    let paramsString = params.joined(separator: "&")
    return URL(string: "\(settings.url)?\(paramsString)")
  }
  
  var webView: WKWebView!
  var filePreview: WKWebView!
  var filePreviewFrame: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()
  var safari: SFSafariViewController?
  let closePreviewButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = .white
    return button
  }()
  
  @objc func closePreview(){
    filePreview.load(URLRequest(url: URL(string:"about:blank")!))
    filePreviewFrame.isHidden = true
  }
  public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
               completionHandler: @escaping () -> Void) {

      let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
      alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
          completionHandler()
      }))

      present(alertController, animated: true, completion: nil)
  }


  public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
               completionHandler: @escaping (Bool) -> Void) {

      let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

      alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
          completionHandler(true)
      }))

      alertController.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action) in
          completionHandler(false)
      }))

      present(alertController, animated: true, completion: nil)
  }


  public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
               completionHandler: @escaping (String?) -> Void) {

      let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)

      alertController.addTextField { (textField) in
          textField.text = defaultText
      }

      alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
          if let text = alertController.textFields?.first?.text {
              completionHandler(text)
          } else {
              completionHandler(defaultText)
          }
      }))

      alertController.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action) in
          completionHandler(nil)
      }))

      present(alertController, animated: true, completion: nil)
  }

  //  MARK: LifeCycle
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    let configuration = genWVConfig()
    
    webView = WKWebView(frame: .zero, configuration: configuration)
    webView.uiDelegate = self
    webView.navigationDelegate = self
    webView.allowsBackForwardNavigationGestures = true
    
    filePreview = WKWebView(frame: .zero, configuration: configuration)
    closePreviewButton.addTarget(self, action: #selector(closePreview), for: .touchUpInside)

    UISetup()
    
    if let url = generateUrl() {
      dev{print(mNot, "url", url)}
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }
    
  func UISetup(){
    view.addSubview(webView)
    webView.translatesAutoresizingMaskIntoConstraints = false
    
    var buttonText: String
    switch settings.language {
    case .kk:
      buttonText = "Жабу"
    case .en:
      buttonText = "Close"
    default:
      buttonText = "Закрыть"
    }
    closePreviewButton.setTitle(buttonText, for: .normal)
    
    filePreview.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(filePreviewFrame)
    filePreviewFrame.addSubview(closePreviewButton)
    filePreviewFrame.addSubview(filePreview)
    NSLayoutConstraint.activate([
      filePreviewFrame.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      filePreviewFrame.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      filePreviewFrame.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      filePreviewFrame.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      closePreviewButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      closePreviewButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      closePreviewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      closePreviewButton.heightAnchor.constraint(equalToConstant: 40),
      filePreview.topAnchor.constraint(equalTo: closePreviewButton.bottomAnchor),
      filePreview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      filePreview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      filePreview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
    
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
  }

  //  MARK: Delegation
  open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    let jsonString = settings.prepareData() ?? "{}"
    dev{print(mNot, "sending data ", jsonString)}
    webView.evaluateJavaScript("iosData=\(jsonString)"){ (result, error) in
      if let error = error {
        self.dev{print(mErr, "javascript error", error)}
      }
    }
  }
  
  open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
    if let url = navigationAction.request.url {
      dev{print(mNot, "navigating to", url)}
      if url.absoluteString.contains("static") {
        safari = SFSafariViewController(url: url)
        safari?.delegate = self
        safari?.providesPresentationContextTransitionStyle = true
        safari?.definesPresentationContext = true
        safari?.modalPresentationStyle = UIModalPresentationStyle.popover
        if let safari = safari {
          present(safari, animated: true)
        }
        decisionHandler(.cancel)
        return
      }
    }

    decisionHandler(.allow)
  }
  
  //  MARK: Configuration
  private func genWVConfig() -> WKWebViewConfiguration{
    let preferences = WKPreferences()
    preferences.javaScriptCanOpenWindowsAutomatically = true
    if #available(iOS 13, *){ preferences.isFraudulentWebsiteWarningEnabled = true }
    
    let configuration = WKWebViewConfiguration()
    configuration.allowsAirPlayForMediaPlayback = true
    configuration.allowsInlineMediaPlayback = true
    configuration.allowsPictureInPictureMediaPlayback = true
    configuration.ignoresViewportScaleLimits = true
//    configuration.mediaTypesRequiringUserActionForPlayback = .all // Ломает видео
    if #available(iOS 14, *){
      configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    } else {
      preferences.javaScriptEnabled = true
    }
    configuration.preferences = preferences
    return configuration
  }

}
