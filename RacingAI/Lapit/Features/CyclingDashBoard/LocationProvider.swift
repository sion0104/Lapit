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

    private var isRequestingAuth: Bool = false
    private var isRequestingLocation: Bool = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocationOnce() async throws -> CLLocation {

        // 1) 권한 확보
        var status = manager.authorizationStatus

        if status == .notDetermined {
            status = await requestAuthWithTimeout(seconds: 3.0)

            status = manager.authorizationStatus

            if status != .authorizedWhenInUse && status != .authorizedAlways {
                throw LocationError.permissionDenied
            }
        } else if status == .denied || status == .restricted {
            throw LocationError.permissionDenied
        }

        // 2) 위치 1회 요청
        if isRequestingLocation {
            throw LocationError.inProgress
        }
        isRequestingLocation = true

        return try await withCheckedThrowingContinuation { cont in
            self.locationContinuation = cont
            self.manager.requestLocation()
        }
    }

    // MARK: - Auth

    private func requestAuth() async -> CLAuthorizationStatus {
        await withCheckedContinuation { cont in
            self.authContinuation = cont
            self.manager.requestWhenInUseAuthorization()
        }
    }

    private func requestAuthWithTimeout(seconds: Double) async -> CLAuthorizationStatus {
        if isRequestingAuth {
            // 이미 요청 중이면 현재 status만 반환
            return manager.authorizationStatus
        }
        isRequestingAuth = true
        defer { isRequestingAuth = false }

        let status = await withTaskGroup(of: CLAuthorizationStatus.self) { group in
            group.addTask { [weak self] in
                guard let self else { return await self?.manager.authorizationStatus ?? .notDetermined }
                return await self.requestAuth()
            }
            group.addTask { [weak self] in
                // timeout
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                return await self?.manager.authorizationStatus ?? .notDetermined
            }

            // 먼저 끝난 값을 사용
            let first = await group.next() ?? manager.authorizationStatus
            group.cancelAll()
            return first
        }

        return status
    }

    enum LocationError: LocalizedError {
        case permissionDenied
        case servicesDisabled
        case inProgress
        case unknown

        var errorDescription: String? {
            switch self {
            case .permissionDenied: return "위치 권한이 필요합니다."
            case .servicesDisabled: return "위치 서비스가 꺼져 있습니다."
            case .inProgress: return "위치 정보를 가져오는 중입니다."
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
            self.isRequestingLocation = false

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
            self.isRequestingLocation = false
            self.locationContinuation?.resume(throwing: error)
            self.locationContinuation = nil
        }
    }
}
