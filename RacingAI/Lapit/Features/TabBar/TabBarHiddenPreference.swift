import SwiftUI

struct TabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

extension View { 
    func tabBarHidden(_ hidden: Bool) -> some View {
        preference(key: TabBarHiddenPreferenceKey.self, value: hidden)
    }
}
