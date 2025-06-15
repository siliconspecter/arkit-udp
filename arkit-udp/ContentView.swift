//
//  ContentView.swift
//  arkit-udp
//
//  Created by siliconspecter on 15/06/2025.
//

import SwiftUI

struct ContentView: View {
    @State var faceTrackingEnabled: Bool = false
    @State var udpConnectionEnabled: Bool = false
    
    @State var ipA: UInt8?
    @State var ipB: UInt8?
    @State var ipC: UInt8?
    @State var ipD: UInt8?
    @State var port: UInt16?
    
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
                    .disabled(ipA == nil || ipB == nil || ipC == nil || ipD == nil || port == nil)
                    
                    LabeledContent("IP Address") {
                        HStack {
                            TextField("192", value: $ipA, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                            
                            TextField("168", value: $ipB, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                            
                            TextField("1", value: $ipC, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                            
                            TextField("1", value: $ipD, format: .number)
                                .disabled(udpConnectionEnabled)
                                .frame(width: 40)
                                .fixedSize(horizontal: true, vertical: false)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    LabeledContent("Port") {
                        TextField("6772", value: $port, format: .number)
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
