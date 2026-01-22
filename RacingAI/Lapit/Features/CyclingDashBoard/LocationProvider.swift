import CoreLocation

@MainActor
final class LocationProvider: NSObject {

    private let manager: CLLocationManager = {
        let m = CLLocationManager()
        m.desiredAccuracy = kCLLocationAccuracyKilometer
        return m
    }()

    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocationOnce() async throws -> CLLocation {
        // 1) 권한 확보
        let status = manager.authorizationStatus
        if status == .notDetermined {
            let newStatus = await requestAuth()
            if newStatus != .authorizedWhenInUse && newStatus != .authorizedAlways {
                throw LocationError.permissionDenied
            }
        } else if status == .denied || status == .restricted {
            throw LocationError.permissionDenied
        }

        // 2) 위치 1회 요청
        return try await withCheckedThrowingContinuation { cont in
            self.locationContinuation = cont
            self.manager.requestLocation()
        }
    }

    private func requestAuth() async -> CLAuthorizationStatus {
        await withCheckedContinuation { cont in
            self.authContinuation = cont
            self.manager.requestWhenInUseAuthorization()
        }
    }

    enum LocationError: LocalizedError {
        case permissionDenied
        case unknown

        var errorDescription: String? {
            switch self {
            case .permissionDenied: return "위치 권한이 필요합니다."
            case .unknown: return "위치를 가져올 수 없습니다."
            }
        }
    }
}

extension LocationProvider: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authContinuation?.resume(returning: status)
            self.authContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last
        Task { @MainActor in
            if let loc {
                self.locationContinuation?.resume(returning: loc)
            } else {
                self.locationContinuation?.resume(throwing: LocationProvider.LocationError.unknown)
            }
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationContinuation?.resume(throwing: error)
            self.locationContinuation = nil
        }
    }
}
