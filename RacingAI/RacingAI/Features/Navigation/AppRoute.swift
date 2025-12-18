import Foundation

enum PasswordVerifyFlow: Hashable {
    case editInfo
    case changePassword
}

enum AppRoute: Hashable {
    case passwordVerify(PasswordVerifyFlow)
    case editInfo
    case changePassword
    case termOfUse
    case privacyPolicy
}
