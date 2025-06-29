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

enum EyePosition {
    case neutral, up, down, left, right
    
    func title() -> String {
        switch self {
        case .neutral: return "Neutral"
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        }
    }
    
    func systemImage() -> String {
        switch self {
        case .neutral: return "circle"
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
    
    func update(arFaceAnchor: ARFaceAnchor, leftBlendShapeLocation: ARFaceAnchor.BlendShapeLocation, rightBlendShapeLocation: ARFaceAnchor.BlendShapeLocation, upBlendShapeLocation: ARFaceAnchor.BlendShapeLocation, downBlendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> EyePosition? {
        
        switch self {
        case .up:
            if let value = arFaceAnchor.getBlendShape(blendShapeLocation: upBlendShapeLocation), value.compare(0.05) == .orderedAscending {
                return self
            }
        case .down:
            if let value = arFaceAnchor.getBlendShape(blendShapeLocation: downBlendShapeLocation), value.compare(0.05) == .orderedAscending {
                return self
            }
        case .left:
            if let value = arFaceAnchor.getBlendShape(blendShapeLocation: leftBlendShapeLocation), value.compare(0.05) == .orderedAscending {
                return self
            }
        case .right:
            if let value = arFaceAnchor.getBlendShape(blendShapeLocation: rightBlendShapeLocation), value.compare(0.05) == .orderedAscending {
                return self
            }
        case .neutral: break
        }
        
        if let value = arFaceAnchor.getBlendShape(blendShapeLocation: upBlendShapeLocation), value.compare(0.15) == .orderedDescending {
            return .up
        }
        
        if let value = arFaceAnchor.getBlendShape(blendShapeLocation: downBlendShapeLocation), value.compare(0.15) == .orderedDescending {
            return .down
        }
        
        if let value = arFaceAnchor.getBlendShape(blendShapeLocation: leftBlendShapeLocation), value.compare(0.15) == .orderedDescending {
            return .left
        }
        
        if let value = arFaceAnchor.getBlendShape(blendShapeLocation: rightBlendShapeLocation), value.compare(0.15) == .orderedDescending {
            return .right
        }
        
        return .neutral
    }
}

enum EyeShape {
    case open, halfClosed, closed, wide
    
    func title() -> String {
        switch self {
        case .open: return "Open"
        case .halfClosed: return "Half Closed"
        case .closed: return "Closed"
        case .wide: return "Wide"
        }
    }
    
    func systemImage() -> String {
        switch self {
        case .open: "eye"
        case .halfClosed: "eye.slash"
        case .closed: "eyebrow"
        case .wide: "field.of.view.wide"
        }
    }
    
    func update(arFaceAnchor: ARFaceAnchor, blinkBlendShapeLocation: ARFaceAnchor.BlendShapeLocation, wideBlendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> EyeShape? {
        var output = self
        
        if output == .closed, let value = arFaceAnchor.getBlendShape(blendShapeLocation: blinkBlendShapeLocation), value.compare(0.5) == .orderedAscending {
            output = .halfClosed
        }
        
        if output == .halfClosed, let value = arFaceAnchor.getBlendShape(blendShapeLocation: blinkBlendShapeLocation), value.compare(0.1) == .orderedAscending {
            output = .open
        }
        
        if output == .open, let value = arFaceAnchor.getBlendShape(blendShapeLocation: wideBlendShapeLocation), value.compare(0.15) == .orderedDescending {
            output = .wide
        }
        
        if output == .wide, let value = arFaceAnchor.getBlendShape(blendShapeLocation: wideBlendShapeLocation), value.compare(0.1) == .orderedAscending {
            output = .open
        }
        
        if output == .open, let value = arFaceAnchor.getBlendShape(blendShapeLocation: blinkBlendShapeLocation), value.compare(0.2) == .orderedDescending {
            output = .halfClosed
        }
        
        if output == .halfClosed, let value = arFaceAnchor.getBlendShape(blendShapeLocation: blinkBlendShapeLocation), value.compare(0.75) == .orderedDescending {
            output = .closed
        }
        
        return output
    }
}

class Integrations : NSObject, ObservableObject, ARSessionDelegate {
    var isSmiling = false
    var trackingIdentifier: UUID?
    var leftEyePosition: EyePosition?
    var leftEyeShape: EyeShape?
    var rightEyePosition: EyePosition?
    var rightEyeShape: EyeShape?
    private var arSession: ARSession?
    private var queuedBytes = Data()
    
    @AppStorage("ContentView.faceTrackingEnabled") private var faceTrackingEnabledBool = false
    
    var faceTrackingEnabled: Bool {
        get { self.faceTrackingEnabledBool }
        set {
            self.faceTrackingEnabledBool = newValue
            applySettings(faceTrackingEnabled: faceTrackingEnabled, udpConnectionEnabled: udpConnectionEnabled)
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
            if arSession == nil {
                let newARSession = ARSession()
                newARSession.delegate = self
                newARSession.run(ARFaceTrackingConfiguration())
                arSession = newARSession
            }
        } else if let arSession = self.arSession {
            arSession.pause()
            self.arSession = nil
            self.trackingIdentifier = nil
            self.leftEyePosition = nil
            self.leftEyeShape = nil
            self.rightEyePosition = nil
            self.rightEyeShape = nil
            objectWillChange.send()
        }
    }

    private func appendBlendShape(_ arFaceAnchor: ARFaceAnchor, _ blendShapeLocation: ARFaceAnchor.BlendShapeLocation) -> Void {
        append(Float(truncating: arFaceAnchor.getBlendShape(blendShapeLocation: blendShapeLocation)!))
    }

    private func append(_ value: Float) -> Void {
        queuedBytes.append(contentsOf: withUnsafeBytes(of: value.bitPattern.littleEndian) { Data($0) })
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let arFaceAnchor = anchor as? ARFaceAnchor {
                if self.trackingIdentifier == nil || anchor.identifier == self.trackingIdentifier {
                    let previousLeftEyePosition = leftEyePosition
                    leftEyePosition = (leftEyePosition ?? .neutral).update(arFaceAnchor: arFaceAnchor, leftBlendShapeLocation: .eyeLookOutRight, rightBlendShapeLocation: .eyeLookInRight,  upBlendShapeLocation: .eyeLookUpRight, downBlendShapeLocation: .eyeLookDownRight)
                    
                    let previousLeftEyeShape = leftEyeShape
                    leftEyeShape = (leftEyeShape ?? .open).update(arFaceAnchor: arFaceAnchor, blinkBlendShapeLocation: .eyeBlinkRight, wideBlendShapeLocation: .eyeWideRight)
                    
                    let previousRightEyePosition = rightEyePosition
                    rightEyePosition = (rightEyePosition ?? .neutral).update(arFaceAnchor: arFaceAnchor, leftBlendShapeLocation: .eyeLookInLeft, rightBlendShapeLocation: .eyeLookOutLeft, upBlendShapeLocation: .eyeLookUpLeft, downBlendShapeLocation: .eyeLookDownLeft)
                    
                    let previousRightEyeShape = rightEyeShape
                    rightEyeShape = (rightEyeShape ?? .open).update(arFaceAnchor: arFaceAnchor, blinkBlendShapeLocation: .eyeBlinkLeft, wideBlendShapeLocation: .eyeWideLeft)
                    
                    let previousTrackingIdentifier = trackingIdentifier
                    trackingIdentifier = arFaceAnchor.identifier
                    
                    let changed = leftEyePosition != previousLeftEyePosition || leftEyeShape != previousLeftEyeShape || rightEyePosition != previousRightEyePosition || rightEyeShape != previousRightEyeShape || trackingIdentifier != previousTrackingIdentifier
                    
                    if changed {
                        objectWillChange.send()
                    }
                }
            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if self.trackingIdentifier == anchor.identifier {
                self.trackingIdentifier = nil
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
                            
                            if (integrations.faceTrackingEnabled) {
                                HStack {
                                    Label(integrations.leftEyePosition?.title() ?? "Unknown", systemImage: integrations.leftEyePosition?.systemImage() ?? "questionmark").frame(maxWidth: .infinity)
                                    Label(integrations.rightEyePosition?.title() ?? "Unknown", systemImage: integrations.rightEyePosition?.systemImage() ?? "questionmark").frame(maxWidth: .infinity)
                                }
                                
                                HStack {
                                    Label(integrations.leftEyeShape?.title() ?? "Unknown", systemImage: integrations.leftEyeShape?.systemImage() ?? "questionmark").frame(maxWidth: .infinity)
                                    Label(integrations.rightEyeShape?.title() ?? "Unknown", systemImage: integrations.rightEyeShape?.systemImage() ?? "questionmark").frame(maxWidth: .infinity)
                                }
                                
                                Label("Tracking", systemImage: integrations.trackingIdentifier == nil ? "xmark" : "checkmark")
                                    .foregroundColor(integrations.trackingIdentifier == nil ? .red : .green)
                                    .frame(maxWidth: .infinity)
                            }
                            
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
