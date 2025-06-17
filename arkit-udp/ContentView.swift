//
//  ContentView.swift
//  arkit-udp
//
//  Created by siliconspecter on 15/06/2025.
//

import SwiftUI

class Integrations : ObservableObject {    
    @AppStorage("ContentView.faceTrackingEnabled") private var faceTrackingEnabledBool = false
    
    var faceTrackingEnabled: Bool {
        get { self.faceTrackingEnabledBool }
        set {
            self.faceTrackingEnabledBool = newValue
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
}

struct ContentView: View {
    @ObservedObject var integrations = Integrations()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Face Tracking"), content: {
                    Toggle(isOn: $integrations.faceTrackingEnabled) {
                            Text("Enabled")
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
    }
}

#Preview {
    ContentView()
}
