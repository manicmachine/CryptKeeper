//
//  ContentView.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var actionType: ActionType = .ENCRYPT
    @State private var generateKey: Bool = false
    @State private var maskKey: Bool = false
    @State private var encKey: String = ""
    @State private var xorMask: UInt8 = 0xAA
    @State private var resultingKey: String = ""
    @State private var valueName: String = ""
    @State private var value: String = ""
    @State private var selectedRow: CryptValue.ID? = nil
    @State private var showErrorAlert: Bool = false
    
    private var processValuesDisabled: Bool {
        return encKey.isEmpty
    }
    
    private var addValueDisabled: Bool {
        return valueName.isEmpty || value.isEmpty
    }
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case valueName
        case value
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Form {
                        TextField("Value Name", text: $valueName, prompt: Text("A name for your value"))
                            .focused($focusedField, equals: .valueName)
                            .onSubmit {
                                if valueName.isEmpty { return }
                                else { focusedField = .value }
                            }
                        TextField("Value", text: $value, prompt: Text("Value to be processed"))
                            .focused($focusedField, equals: .value)
                            .onSubmit {
                                if addValueDisabled { return }
                                else {
                                    addValue()
                                    focusedField = .valueName
                                }
                            }
                    }
                }
                
                Divider()
                Button {
                    addValue()
                } label: {
                    Text("Add Value")
                        .font(.headline)
                        .lineLimit(2)
                        .frame(minWidth: 24, maxWidth: 72, minHeight: 10, maxHeight: 50)
                }
                .disabled(addValueDisabled)
            }
            .padding()
            .background(Color.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxHeight: 100)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Toggle(isOn: $generateKey) {
                            Text("Generate key")
                        }
                        .disabled(actionType == .DECRYPT)
                        .help("Generate a new encryption key.")
                        
                        Toggle(isOn: $maskKey) {
                            Text("Mask key")
                        }
                        .help("Mask the key using the HEX value 0xAA. This results in making the key safer to transmit.")
                        
                        Spacer()
                        
                        Picker("Action", selection: $actionType) {
                            Text("Encrypt").tag(ActionType.ENCRYPT)
                            Text("Decrypt").tag(ActionType.DECRYPT)
                        }
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        TextField("Key", text: $encKey, prompt: Text("Encryption Key"))
                            .disabled(generateKey)
                            .onChange(of: encKey) { _, newValue in
                                switch actionType {
                                    case .ENCRYPT:
                                        resultingKey = viewModel.applyMask(for: newValue, with: xorMask)
                                    case .DECRYPT:
                                        resultingKey = viewModel.reverseMask(for: newValue, with: xorMask)
                                }
                            }
                            .onSubmit {
                                if processValuesDisabled { return }
                                else { processValues() }
                            }
                        
                        if generateKey {
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(encKey, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                            .help("Copy key")
                        }
                    }
                    
                    if maskKey {
                        HStack {
                            TextField("Masked Key", text: $resultingKey)
                                .disabled(true)
                            
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(resultingKey, forType: .string)
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                            .help("Copy masked key")
                        }
                        .padding(.top, 8)
                    }
                }
                .onChange(of: generateKey) { _, newValue in
                    if newValue {
                        self.encKey = viewModel.createKey()
                    } else {
                        self.encKey.removeAll()
                    }
                }
                
                Divider()
                
                Button {
                    processValues()
                } label: {
                    Text("Process Values")
                        .font(.headline)
                        .lineLimit(2)
                        .frame(maxWidth: 72, maxHeight: maskKey ? 75 : 50)
                }
                .disabled(processValuesDisabled)
            }
            .padding()
            .background(Color.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxHeight: 135)
            
            Table(of: CryptValue.self, selection: $selectedRow) {
                TableColumn("Name", value: \.name)
                TableColumn("Original", value: \.original)
                TableColumn("Result", value: \.result.unwrapOrEmpty)
            } rows: {
                ForEach(viewModel.values) { value in
                    TableRow(value)
                        .contextMenu {
                            Button("Delete") {
                                viewModel.removeValue(value.id)
                            }
                            
                            Button("Copy Original") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(value.original, forType: .string)
                            }
                            
                            if let result = value.result {
                                Button("Copy Result") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(result, forType: .string)
                                }
                            }
                        }
                }
            }
        }
        .padding()
        .alert("Errors Detected", isPresented: $showErrorAlert, presenting: viewModel.valuesWithErrors) { _ in
            // Use default "OK" action
        } message: { values in
            Text("The following values could failed to be processed: \(viewModel.valuesWithErrors.map { $0.name }.joined(separator: ", "))")
        }

    }
    
    private func addValue() {
        viewModel.addValue(name: valueName, value: value)
        valueName.removeAll()
        value.removeAll()
    }
    
    private func processValues() {
        var key: String
        
        switch actionType {
            case .ENCRYPT:
                key = encKey
            case .DECRYPT:
                key = maskKey ? resultingKey : encKey
        }
        
        viewModel.processValues(performing: actionType, with: key)
        
        if !viewModel.valuesWithErrors.isEmpty {
            showErrorAlert = true
        }
    }
}

extension ContentView {
    @Observable
    class ViewModel {
        private(set) var values = [CryptValue]()
        var valuesWithErrors: [CryptValue] {
            values.filter { val in
                val.hasError
            }
        }
        
        func addValue(name: String, value: String) {
            let val = CryptValue(name: name, original: value)
            
            values.append(val)
        }
        
        func removeValue(_ id: UUID) {
            values.removeAll(where: { $0.id == id })
        }
        
        func createKey() -> String {
            return CryptService.generateKey()
        }
        
        func applyMask(for key: String, with mask: UInt8) -> String {
            return CryptService.xorStringToBase64(key, with: mask)
        }
        
        func reverseMask(for key: String, with mask: UInt8) -> String {
            return CryptService.decodeXorBase64(key, with: mask)
        }
        
        func processValues(performing action: ActionType, with key: String) {
            for val in values {
                val.hasError = false
                var result: String
                
                do {
                    switch action {
                        case .ENCRYPT:
                            result = try CryptService.encryptValue(val.original, using: key)
                        case .DECRYPT:
                            result = try CryptService.decryptValue(val.original, using : key)
                    }
                    
                    val.result = result
                } catch {
                    val.hasError = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
