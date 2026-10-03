import CoreLocation
import CoreMotion
import Foundation

/// Works out whether the car is parked or moving, from GPS speed backed up by motion activity.
/// Video in DriveIn is only unlocked in the `.parked` state.
@MainActor
final class DriveMonitor: NSObject, ObservableObject {
    enum State: Equatable {
        case checking      // no reliable reading yet
        case parked
        case moving
        case noPermission  // location access refused
    }

    @Published private(set) var state: State = .checking
    @Published private(set) var speedKmh: Double = 0

    var videoUnlocked: Bool { state == .parked }

    // Start counting as moving at 10 km/h; count as parked only after 8 s below 4 km/h.
    private let moveThreshold = 10.0
    private let stopThreshold = 4.0
    private let stopHold: TimeInterval = 8

    private let location = CLLocationManager()
    private let motion = CMMotionActivityManager()
    private var automotive = false
    private var slowSince: Date?
    private var started = false

    override init() {
        super.init()
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        location.activityType = .automotiveNavigation
        location.distanceFilter = kCLDistanceFilterNone
    }

    func start() {
        guard !started else { return }
        started = true
        applyAuthorization(location.authorizationStatus)

        if CMMotionActivityManager.isActivityAvailable() {
            motion.startActivityUpdates(to: .main) { [weak self] activity in
                guard let activity else { return }
                let driving = activity.automotive && activity.confidence != .low
                Task { @MainActor in
                    self?.automotive = driving
                    self?.evaluate(kmh: nil)
                }
            }
        }
    }

    private func applyAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            location.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if state == .noPermission { state = .checking }
            location.startUpdatingLocation()
        case .denied, .restricted:
            location.stopUpdatingLocation()
            state = .noPermission
        @unknown default:
            state = .noPermission
        }
    }

    /// `kmh` is nil when only the motion activity changed.
    private func evaluate(kmh: Double?) {
        guard state != .noPermission else { return }
        if let kmh { speedKmh = kmh }

        let speed = kmh ?? speedKmh
        let now = Date()

        if speed >= moveThreshold || (automotive && kmh == nil && state == .moving) {
            slowSince = nil
            state = .moving
            return
        }

        if speed < stopThreshold && !automotive {
            if slowSince == nil { slowSince = now }
            if state == .checking || now.timeIntervalSince(slowSince ?? now) >= stopHold {
                state = .parked
            }
        } else if speed >= stopThreshold {
            // Rolling slowly: keep whatever state we had, but restart the parked timer.
            slowSince = nil
        }
    }
}

extension DriveMonitor: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last, last.speed >= 0, last.horizontalAccuracy >= 0 else { return }
        let kmh = last.speed * 3.6
        Task { @MainActor in self.evaluate(kmh: kmh) }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in self.applyAuthorization(status) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep the last known state. A missing fix never unlocks video.
    }
}
