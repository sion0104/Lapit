import Foundation

@MainActor
final class WorkoutUploadRecorder: ObservableObject {

    private(set) var startTime: Date?
    private var samples: [LiveMetricsPayload] = []

    private var isRecording = false
    private var isStopping = false

    var stopFlushDelaySec: Double = 0.7

    var detailIntervalSec: Double = 5.0

    var maxDetailCount: Int = 2000

    var ignoreZeroSpeedDetails: Bool = true
    var ignoreZeroHeartRateDetails: Bool = false

    // MARK: - Public
    func start() {
        startTime = Date()
        samples.removeAll()
        isRecording = true
        isStopping = false
    }

    func append(_ payload: LiveMetricsPayload) {
        guard isRecording, !isStopping else { return }
        samples.append(payload)
    }

    func stopAndUpload(
        workoutType: String,
        durationSec: Int,
        latestProvider: @escaping () -> LiveMetricsPayload?
    ) async throws {

        guard let startTime else { return }
        guard isRecording else { return }

        isStopping = true

        if stopFlushDelaySec > 0 {
            try? await Task.sleep(nanoseconds: UInt64(stopFlushDelaySec * 1_000_000_000))
        }

        if let latest = latestProvider(), isValidFinalPayload(latest) {
            samples.append(latest)
        }

        let rawEndTime = samples.last?.timestamp ?? Date()

        let endTime = max(rawEndTime, startTime)

        let computedDurationSec = max(0, Int(endTime.timeIntervalSince(startTime).rounded()))

        let request = buildRequest(
            workoutType: workoutType,
            startTime: startTime,
            endTime: endTime,
            durationSec: computedDurationSec
        )


        let _: CommonResponse<EmptyData> = try await APIClient.shared.post("/v1/workout", body: request)

        reset()
    }

    func reset() {
        startTime = nil
        samples.removeAll()
        isRecording = false
        isStopping = false
    }

    // MARK: - Build Request

    private func buildRequest(
        workoutType: String,
        startTime: Date,
        endTime: Date,
        durationSec: Int
    ) -> WorkoutSaveRequest {

        let checkDate = WorkoutDateFormatter.checkDateString(startTime)
        let last = samples.last

        let totalCalories = NumberSanitizer.normalize(last?.activeEnergyKcal, scale: 2, min: 0)

        let hrValues = samples
            .compactMap { $0.heartRateBPM }
            .filter { $0.isFinite && $0 > 0 }

        let avgHeartRateRaw = hrValues.isEmpty ? 0 : hrValues.reduce(0, +) / Double(hrValues.count)
        let avgHeartRate = NumberSanitizer.round(NumberSanitizer.safe(avgHeartRateRaw), scale: 2)

        let speedValuesMps = samples
            .compactMap { $0.speedMps }
            .map { NumberSanitizer.safe($0) }
            .filter { $0.isFinite && $0 > 0 }

        let avgSpeedRaw = speedValuesMps.isEmpty ? 0 : speedValuesMps.reduce(0, +) / Double(speedValuesMps.count)
        let maxSpeedRaw = speedValuesMps.max() ?? 0

        let avgSpeed = NumberSanitizer.round(avgSpeedRaw, scale: 3)
        let maxSpeed = NumberSanitizer.round(maxSpeedRaw, scale: 3)

        let totalDistance = NumberSanitizer.round(avgSpeed * Double(max(durationSec, 0)), scale: 2)

        let avgPower = 0.0

        let details = makeDetailsDownsampled(endTime: endTime)

        return WorkoutSaveRequest(
            workoutType: WorkoutTypeMapper.toServer(workoutType),
            checkDate: checkDate,
            startTime: WorkoutDateFormatter.isoString(startTime),
            endTime: WorkoutDateFormatter.isoString(endTime),
            durationSec: durationSec,
            totalDistance: totalDistance,
            totalCaloriesKcal: totalCalories,
            avgHeartRate: avgHeartRate,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            avgPower: avgPower,
            details: details
        )
    }

    private func makeDetailsDownsampled(endTime: Date) -> [WorkoutDetailRequest] {
        guard !samples.isEmpty else { return [] }

        var interval = detailIntervalSec

        if maxDetailCount > 0 {
            let totalSec = samples.last!.timestamp.timeIntervalSince(samples.first!.timestamp)
            let estimated = Int(totalSec / max(interval, 1)) + 1
            if estimated > maxDetailCount {
                interval = 10.0
            }
        }

        var result: [WorkoutDetailRequest] = []
        var lastPickedAt: Date? = nil

        for s in samples {
            let now = s.timestamp

            if let last = lastPickedAt, now.timeIntervalSince(last) < interval {
                continue
            }

            let hr = NumberSanitizer.safe(s.heartRateBPM)
            let speed = NumberSanitizer.safe(s.speedMps)

            if ignoreZeroSpeedDetails, speed <= 0 {
                continue
            }

            if ignoreZeroHeartRateDetails, hr <= 0 {
                continue
            }
            
            if now > endTime { continue }
            

            result.append(
                WorkoutDetailRequest(
                    measureAt: WorkoutDateFormatter.isoString(now),
                    heartRate: NumberSanitizer.round(hr, scale: 2),
                    speed: NumberSanitizer.round(speed, scale: 2),
                    power: nil
                )
            )

            lastPickedAt = now

            if maxDetailCount > 0, result.count >= maxDetailCount {
                break
            }
        }

        return result
    }

    private func isValidFinalPayload(_ p: LiveMetricsPayload) -> Bool {
        let hrOk = NumberSanitizer.safe(p.heartRateBPM) > 0
        let distOk = NumberSanitizer.safe(p.distanceMeters) > 0
        let kcalOk = NumberSanitizer.safe(p.activeEnergyKcal) > 0
        return hrOk || distOk || kcalOk
    }
}
