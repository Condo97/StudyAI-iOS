//
//  AttachURLView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import PDFKit
import SwiftUI

struct AttachURLButton: View, KeyboardReadable {
    
    @Binding var url: URL?
    var subtitle: LocalizedStringKey// = "Chat about an online source, lecture, assignment, more."
    
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingURLSpecifierPopup: Bool = false
    
    @State private var alertShowingErrorReading: Bool = false
    
    @State private var submitUrlButtonDisabled: Bool = false
    
    @State private var urlFieldText: String = ""
    @State private var browserURL: URL?
    
    @State private var keyboardStatus: KeyboardStatus?
    
    var body: some View {
        Button(action: {
            isShowingURLSpecifierPopup = true
        }) {
            VStack {
                HStack {
//                    Text(Image(systemName: "link"))
                    Text("🌎")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding(4)
                        .frame(width: 38.0, height: 38.0)
                        .background(Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                    Text("Webpage")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(.custom(Constants.FontName.body, size: 10.0))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingURLSpecifierPopup) {
            VStack {
                // Pill
                RoundedRectangle(cornerRadius: 28.0)
                    .foregroundStyle(Colors.textOnBackgroundColor)
                    .frame(width: 28.0, height: 2.0)
                    .padding(.vertical)
                
                // Enter URL Text Field and Submit Button
                HStack {
                    HStack {
                        // Enter URL Text Field
                        TextField("https://", text: $urlFieldText)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                            .minimumScaleFactor(0.6)
                            .onSubmit {
                                Task {
                                    await updateWebContentForUrlFieldText()
                                }
                            }
                        
                        // Paste button
                        Button(action: {
                            // Paste to urlFieldText if clipboard text can be unwrapped and is not empty
                            if let pasteText = PasteboardHelper.paste(), !pasteText.isEmpty {
                                self.urlFieldText = pasteText
                            }
                        }) {
                            Text(Image(systemName: "doc.on.clipboard.fill"))
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        }
                    }
                    .padding([.leading, .trailing])
                    .frame(height: 60.0)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Button(action: {
                        Task {
                            if let validUrlFieldURL = await getValidUrlFieldURL() {
                                self.url = validUrlFieldURL
                                
                                self.isShowingURLSpecifierPopup = false
                            } else {
                                self.alertShowingErrorReading = true
                            }
                        }
                    }) {
                        Text(Image(systemName: "chevron.right"))
                            .font(.custom(Constants.FontName.body, size: 28.0))
                        //                                .padding()
                            .frame(width: 60.0, height: 60.0)
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                    .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                    .disabled((!(keyboardStatus == .isShowing || keyboardStatus == .willShow) && submitUrlButtonDisabled) || urlFieldText.isEmpty)
                    .opacity((!(keyboardStatus == .isShowing || keyboardStatus == .willShow) && submitUrlButtonDisabled) || urlFieldText.isEmpty ? 0.4 : 1.0)
                }
                
                // Enter URL Description
                HStack {
                    Text("Enter a URL to analyze with AI.")
                        .font(.custom(Constants.FontName.body, size: 12.0))
                        .opacity(0.6)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding([.leading, .trailing])
            .background(Colors.background)
            .presentationDetents([.height(150.0)])
        }
        .onChange(of: browserURL) { newValue in
            // Set urlFieldText if browserURL was changed, since user may have tapped on a link in the browser TODO: Is this a good implementation
            if let newValue = newValue {
                DispatchQueue.main.async {
                    self.urlFieldText = newValue.absoluteString
                }
            }
        }
//        .onChange(of: urlFieldText) { newValue in
//            // Set url field to disabled whenever url field text is changed
//            self.submitUrlButtonDisabled = true
//            
//            // Get valid url field url and update previewURL and submitUrlButtonDisabled
//            Task {
//                if let validUrlFieldURL = await getValidUrlFieldURL() {
//                    DispatchQueue.main.async {
//                        // Set browserURL
//                        self.browserURL = validUrlFieldURL
//                        
//                        // Set submitUrlButtonDisabled to false since a valid URL was found
//                        self.submitUrlButtonDisabled = false
//                    }
//                }
//            }
//        }
        .onReceive(keyboardPublisher) { newValue in // TODO: This seems to be the latest code and I'm gonna repeat this but it should be abstracted and moved so that the reference is more straightforeward
            DispatchQueue.main.async {
                self.keyboardStatus = newValue
            }
        }
        .alert("Couldn't Read Link", isPresented: $alertShowingErrorReading, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("There was an issue reading your URL. Please make sure it is valid and try again.")
        }
    }
    
    private func updateWebContentForUrlFieldText() async {
        // Set submitUrlButtonDisabled to true
        await MainActor.run {
            self.submitUrlButtonDisabled = true
        }
        
        // Get valid url field url and update previewURL and submitUrlButtonDisabled
        if let validUrlFieldURL = await getValidUrlFieldURL() {
            DispatchQueue.main.async {
                // Set browserURL
                self.browserURL = validUrlFieldURL
                
                // Set submitUrlButtonDisabled to false since a valid URL was found
                self.submitUrlButtonDisabled = false
            }
        }
    }
    
    private func getValidUrlFieldURL() async -> URL? {
        if let urlFieldURL = URL(string: "https://\(urlFieldText)") {
            do {
                // Get response and see if it throws an error or not
                let (data, urlResponse) = try await URLSession.shared.data(for: URLRequest(url: urlFieldURL))
                
                // Valid url, return
                return urlFieldURL
            } catch {
                // Not a valid url, continue TODO: Handle Errors if Necessary
            }
        }
        
        if let urlFieldURL = URL(string: urlFieldText) {
            do {
                // Get response and see if it throws an error or not
                let (data, urlResponse) = try await URLSession.shared.data(for: URLRequest(url: urlFieldURL))
                
                // Valid url, return
                return urlFieldURL
            } catch {
                // Not a valid url, continue TODO: Handle Errors if Necessary
            }
        }
        
        return nil
    }
    
    private func read(from url: URL) -> String? {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            return try String(contentsOf: url)
        } catch {
            // If couldn't from String, try getting as a PDF
            print("Could not get as String, trying as PDF...")
        }
        
        if let pdf = PDFDocument(url: url) {
            let pageCount = pdf.pageCount
            let content = NSMutableAttributedString()
            
            for i in 0..<pageCount {
                // Get page, otherwise continue
                guard let page = pdf.page(at: i) else {
                    continue
                }
                
                // Get pageContent, otherwise continue
                guard let pageContent = page.attributedString else {
                    continue
                }
                
                // Append pageContent to content
                content.append(pageContent)
            }
            
            return content.string
        }
        
        return nil
    }
    
}

//#Preview {
//    
//    ZStack {
//        VStack {
//            Spacer()
//            
//            HStack {
//                Spacer()
//                
//                AttachURLButton(
//                    url: .constant(nil),
//                    subtitle: "Chat about an online source, lecture, assignment, more.")
//                    .foregroundStyle(Colors.text)
//                    .padding()
//                    .background(Colors.foreground)
//                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                
//                Spacer()
//            }
//            
//            Spacer()
//        }
//    }
//    .background(Colors.background)
//    
//}
