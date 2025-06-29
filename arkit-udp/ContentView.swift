//
//  ContentView.swift
//  arkit-udp
//
//  Created by siliconspecter on 15/06/2025.
//

import SwiftUI
import ARKit

extension ARFaceAnchor {
    func getBlendShape(blendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> NSNumber? {
        if let blendShape = self.blendShapes.first(where: {$0.key == blendShapeLocation}) {
            return blendShape.value
        } else {
            return nil
        }
    }
}

class Integrations : NSObject, ObservableObject, ARSessionDelegate {
    private var arSession: ARSession?
    var trackedFaces = 0
    var timer: Timer?
    var successfulMessages = 0
    var connectionFailed = false
    private var queuedBytes = Data()

    @AppStorage("ContentView.faceTrackingEnabled") private var faceTrackingEnabledBool = false

    var faceTrackingEnabled: Bool {
        get { self.faceTrackingEnabledBool }
        set {
            self.faceTrackingEnabledBool = newValue
            applySettings(faceTrackingEnabled: faceTrackingEnabled)
        }
    }

    @AppStorage("ContentView.xOffset") private var xOffsetDouble: Double?

    var xOffset: Float? {
        get { self.xOffsetDouble.flatMap { Float($0) } }
        set {
            self.xOffsetDouble = newValue.map { Double($0) }
        }
    }

    @AppStorage("ContentView.yOffset") private var yOffsetDouble: Double?

    var yOffset: Float? {
        get { self.yOffsetDouble.flatMap { Float($0) } }
        set {
            self.yOffsetDouble = newValue.map { Double($0) }
        }
    }

    @AppStorage("ContentView.zOffset") private var zOffsetDouble: Double?

    var zOffset: Float? {
        get { self.zOffsetDouble.flatMap { Float($0) } }
        set {
            self.zOffsetDouble = newValue.map { Double($0) }
        }
    }

    @AppStorage("ContentView.udpConnectionEnabled") private var udpConnectionEnabledBool = false

    var udpConnectionEnabled: Bool {
        get { self.udpConnectionEnabledBool }
        set {
            successfulMessages = 0
            connectionFailed = false
            self.udpConnectionEnabledBool = newValue
        }
    }

    @AppStorage("ContentView.ipA") private var ipAInt: Int?

    var ipA: UInt8? {
        get { self.ipAInt.flatMap { UInt8(exactly: $0) } }
        set {
            self.ipAInt = newValue.map { Int($0) }
        }
    }

    @AppStorage("ContentView.ipB") private var ipBInt: Int?

    var ipB: UInt8? {
        get { self.ipBInt.flatMap { UInt8(exactly: $0) } }
        set {
            self.ipBInt = newValue.map { Int($0) }
        }
    }

    @AppStorage("ContentView.ipC") private var ipCInt: Int?

    var ipC: UInt8? {
        get { self.ipCInt.flatMap { UInt8(exactly: $0) } }
        set {
            self.ipCInt = newValue.map { Int($0) }
        }
    }

    @AppStorage("ContentView.ipD") private var ipDInt: Int?

    var ipD: UInt8? {
        get { self.ipDInt.flatMap { UInt8(exactly: $0) } }
        set {
            self.ipDInt = newValue.map { Int($0) }
        }
    }

    @AppStorage("ContentView.port") private var portInt: Int?

    var port: UInt16? {
        get { self.portInt.flatMap { UInt16(exactly: $0) } }
        set {
            self.portInt = newValue.map { Int($0) }
        }
    }

    override init () {
        super.init()
        applySettings(faceTrackingEnabled: faceTrackingEnabled)
    }

    deinit {
        applySettings(faceTrackingEnabled: false)
    }

    private func applySettings(faceTrackingEnabled: Bool) {
        if faceTrackingEnabled && ARFaceTrackingConfiguration.isSupported && AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            trackedFaces = 0
            objectWillChange.send()

            if arSession == nil {
                let newARSession = ARSession()
                newARSession.delegate = self
                newARSession.run(ARFaceTrackingConfiguration())
                arSession = newARSession
            }
        } else if let arSession = self.arSession {
            arSession.pause()
            self.arSession = nil

            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
        }
    }

    private func appendBlendShape(_ arFaceAnchor: ARFaceAnchor, _ blendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> Void {
        append(Float(truncating: arFaceAnchor.getBlendShape(blendShapeLocation: blendShapeLocation)!))
    }

    private func append(_ value: Float) -> Void {
        queuedBytes.append(contentsOf: withUnsafeBytes(of: value.bitPattern.littleEndian) { Data($0) })
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.trackedFaces = 0
            self.objectWillChange.send()
        }

        trackedFaces = 0

        for anchor in anchors {
            if let arFaceAnchor = anchor as? ARFaceAnchor {
                trackedFaces += 1
                queuedBytes.append(contentsOf: withUnsafeBytes(of: UInt32(128).littleEndian) { Data($0) })
                queuedBytes.append(contentsOf: withUnsafeBytes(of: UInt32(1).littleEndian) { Data($0) })
                queuedBytes.append(contentsOf: withUnsafeBytes(of: arFaceAnchor.identifier) { Data($0) })
                append(arFaceAnchor.transform[3][2] + xOffset!)
                append(-arFaceAnchor.transform[3][0] + yOffset!)
                append(arFaceAnchor.transform[3][1] + zOffset!)
                append(arFaceAnchor.transform[2][2])
                append(-arFaceAnchor.transform[2][0])
                append(arFaceAnchor.transform[2][1])
                append(arFaceAnchor.transform[1][2])
                append(-arFaceAnchor.transform[1][0])
                append(arFaceAnchor.transform[1][1])
                appendBlendShape(arFaceAnchor, .eyeBlinkLeft)
                appendBlendShape(arFaceAnchor, .eyeBlinkRight)
                appendBlendShape(arFaceAnchor, .eyeLookUpLeft)
                appendBlendShape(arFaceAnchor, .eyeLookUpRight)
                appendBlendShape(arFaceAnchor, .eyeLookDownLeft)
                appendBlendShape(arFaceAnchor, .eyeLookDownRight)
                appendBlendShape(arFaceAnchor, .eyeLookInLeft)
                appendBlendShape(arFaceAnchor, .eyeLookOutRight)
                appendBlendShape(arFaceAnchor, .eyeLookInRight)
                appendBlendShape(arFaceAnchor, .eyeLookOutLeft)
                appendBlendShape(arFaceAnchor, .eyeWideLeft)
                appendBlendShape(arFaceAnchor, .eyeWideRight)
                appendBlendShape(arFaceAnchor, .mouthSmileLeft)
                appendBlendShape(arFaceAnchor, .mouthSmileRight)
                appendBlendShape(arFaceAnchor, .mouthFunnel)
                appendBlendShape(arFaceAnchor, .mouthPressLeft)
                appendBlendShape(arFaceAnchor, .mouthPressRight)
                appendBlendShape(arFaceAnchor, .jawOpen)
            }
        }

        if queuedBytes.isEmpty {
          objectWillChange.send()
        } else {
            let toSend = queuedBytes
            queuedBytes = Data()

            if udpConnectionEnabled {
                toSend.withUnsafeBytes { ptr in
                    let socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)

                    if socket == -1 {
                        successfulMessages = 0
                        connectionFailed = true
                    } else {
                        var address = sockaddr_in()
                        address.sin_len = UInt8(MemoryLayout.size(ofValue: address))
                        address.sin_port = port!.bigEndian
                        address.sin_family = sa_family_t(AF_INET)
                        address.sin_addr.s_addr = UInt32(ipD!) << 24 | UInt32(ipC!) << 16 | UInt32(ipB!) << 8 | UInt32(ipA!)

                        let length = socklen_t(address.sin_len)

                        withUnsafePointer(to: &address, { addressPointer in
                            addressPointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { reboundAddressPointer in
                                let sendError = sendto(socket, ptr.baseAddress, toSend.count, MSG_DONTWAIT, reboundAddressPointer, length)

                                if sendError == toSend.count {
                                    successfulMessages += 1
                                    connectionFailed = false
                                } else {
                                    successfulMessages = 0
                                    connectionFailed = true
                                }
                            }
                        })
                    }

                    let closeError = close(socket)

                    if closeError == -1 {
                        successfulMessages = 0
                        connectionFailed = true
                    }

                    objectWillChange.send()
                }
            } else {
              objectWillChange.send()
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var integrations = Integrations()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Face Tracking"), content: {
                    if ARFaceTrackingConfiguration.isSupported {
                        switch AVCaptureDevice.authorizationStatus(for: .video) {
                        case .authorized:
                            Toggle(isOn: $integrations.faceTrackingEnabled.animation())
                            {
                                Text("Enabled")
                            }
                            .disabled(integrations.xOffset == nil || integrations.yOffset == nil || integrations.zOffset == nil)

                        case .denied:
                            Text("You have denied this app's access to the camera.")
                                .foregroundColor(.red)

                            Button(action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(appSettings) {
                                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                                    }
                                }
                            }) {
                                Text("Visit Settings to grant permissions")
                            }

                        case .restricted:
                            Text("You have restricted this app's access to the camera.")
                                .foregroundColor(.red)

                            Button(action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(appSettings) {
                                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                                    }
                                }
                            }) {
                                Text("Visit Settings to grant permissions")
                            }

                        case .notDetermined:
                            Toggle(isOn: $integrations.faceTrackingEnabled.animation()) {
                                Text("Enabled")
                                    .onAppear() {
                                        if integrations.faceTrackingEnabled {
                                            AVCaptureDevice.requestAccess(for: .video) { granted in
                                                DispatchQueue.main.async {
                                                    integrations.faceTrackingEnabled = granted
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: integrations.faceTrackingEnabled) {
                                        if integrations.faceTrackingEnabled {
                                            AVCaptureDevice.requestAccess(for: .video) { granted in
                                                DispatchQueue.main.async {
                                                    integrations.faceTrackingEnabled = granted
                                                }
                                            }
                                        }
                                    }
                            }
                            .disabled(integrations.xOffset == nil || integrations.yOffset == nil || integrations.zOffset == nil)
                        }
                    } else {
                        Text("This device does not support face tracking.")
                            .foregroundColor(.red)
                    }

                    LabeledContent("Sensor Location") {
                        HStack {
                            TextField("0.0", value: $integrations.xOffset, format: .number)
                                .disabled(integrations.faceTrackingEnabled)
                                .frame(width: 50)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numbersAndPunctuation)

                            TextField("0.0", value: $integrations.yOffset, format: .number)
                                .disabled(integrations.faceTrackingEnabled)
                                .frame(width: 50)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numbersAndPunctuation)

                            TextField("0.0", value: $integrations.zOffset, format: .number)
                                .disabled(integrations.faceTrackingEnabled)
                                .frame(width: 50)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numbersAndPunctuation)
                        }
                    }

                    if integrations.faceTrackingEnabled {
                        if integrations.trackedFaces == 0 {
                            Text("No faces have been detected recently.").foregroundColor(.red)
                        } else {
                            Text("\(integrations.trackedFaces) face(s) detected.").foregroundColor(.green)
                        }
                    }
                })

                Section(header: Text("UDP Connection"), content: {
                    Toggle(isOn: $integrations.udpConnectionEnabled) {
                            Text("Enabled")
                    }
                    .disabled(integrations.ipA == nil || integrations.ipB == nil || integrations.ipC == nil || integrations.ipD == nil || integrations.port == nil)

                    LabeledContent("IP Address") {
                        HStack {
                            TextField("192", value: $integrations.ipA, format: .number)
                                .disabled(integrations.udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)

                            TextField("168", value: $integrations.ipB, format: .number)
                                .disabled(integrations.udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)

                            TextField("1", value: $integrations.ipC, format: .number)
                                .disabled(integrations.udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)

                            TextField("1", value: $integrations.ipD, format: .number)
                                .disabled(integrations.udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                        }
                    }

                    LabeledContent("Port") {
                        TextField("6772", value: $integrations.port, format: .number)
                            .disabled(integrations.udpConnectionEnabled)
                            .keyboardType(.numberPad)
                    }

                    if integrations.udpConnectionEnabled {
                        if integrations.connectionFailed {
                            Text("Connection has failed; will retry...").foregroundColor(.red)
                        } else if integrations.successfulMessages == 0 {
                            Text("Waiting...").foregroundColor(.yellow)
                        } else {
                            Text("Connection succeeded; \(integrations.successfulMessages) message(s) sent successfully.").foregroundColor(.green)
                        }
                    }
                })
            }
            .navigationBarTitle("ARKit-UDP")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
