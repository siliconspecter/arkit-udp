//
//  ContentView.swift
//  arkit-udp
//
//  Created by siliconspecter on 15/06/2025.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("ContentView.faceTrackingEnabled") private var faceTrackingEnabled = false
    @SceneStorage("ContentView.udpConnectionEnabled") private var udpConnectionEnabled = false
    
    @SceneStorage("ContentView.ipA") private var ipAInt: Int?
    var ipA: Binding<UInt8?> {
        Binding(
            get: { ipAInt.flatMap { UInt8(exactly: $0) } },
            set: { ipAInt = $0.map { Int($0) } }
        )
    }
    
    @SceneStorage("ContentView.ipB") private var ipBInt: Int?
    var ipB: Binding<UInt8?> {
        Binding(
            get: { ipBInt.flatMap { UInt8(exactly: $0) } },
            set: { ipBInt = $0.map { Int($0) } }
        )
    }
    
    @SceneStorage("ContentView.ipC") private var ipCInt: Int?
    var ipC: Binding<UInt8?> {
        Binding(
            get: { ipCInt.flatMap { UInt8(exactly: $0) } },
            set: { ipCInt = $0.map { Int($0) } }
        )
    }
    
    @SceneStorage("ContentView.ipD") private var ipDInt: Int?
    var ipD: Binding<UInt8?> {
        Binding(
            get: { ipDInt.flatMap { UInt8(exactly: $0) } },
            set: { ipDInt = $0.map { Int($0) } }
        )
    }
    
    @SceneStorage("ContentView.port") private var portInt: Int?
    var port: Binding<UInt16?> {
        Binding(
            get: { portInt.flatMap { UInt16(exactly: $0) } },
            set: { portInt = $0.map { Int($0) } }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Face Tracking"), content: {
                    Toggle(isOn: $faceTrackingEnabled) {
                            Text("Enabled")
                    }
                })
                
                Section(header: Text("UDP Connection"), content: {
                    Toggle(isOn: $udpConnectionEnabled) {
                            Text("Enabled")
                    }
                    .disabled(ipAInt == nil || ipBInt == nil || ipCInt == nil || ipDInt == nil || portInt == nil)
                    
                    LabeledContent("IP Address") {
                        HStack {
                            TextField("192", value: ipA, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                            
                            TextField("168", value: ipB, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                            
                            TextField("1", value: ipC, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                            
                            TextField("1", value: ipD, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    LabeledContent("Port") {
                        TextField("6772", value: port, format: .number)
                            .disabled(udpConnectionEnabled)
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
