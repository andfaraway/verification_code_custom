import Flutter
import UIKit

public class SwiftVerificationCodeCustomPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "verification_code_custom", binaryMessenger: registrar.messenger())
    let instance = SwiftVerificationCodeCustomPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
