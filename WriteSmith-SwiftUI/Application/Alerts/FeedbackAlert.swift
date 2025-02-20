//
//  FeedbackAlert.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/2/24.
//

import Foundation
import SwiftUI

struct FeedbackAlert: ViewModifier {
    
    @Binding var isPresented: Bool
    
    @State private var feedbackText: String = ""
    
    
    func body(content: Content) -> some View {
        content
            .alert("Submit Feedback", isPresented: $isPresented, actions: {
                TextField("Tap to Start Typing...", text: $feedbackText)
                
                Button("Submit", action: {
                    // Send feedbackText to server, clear, and dismiss
                    Task {
                        let submitFeedbackRequest: SubmitFeedbackRequest
                        do {
                            submitFeedbackRequest = SubmitFeedbackRequest(
                                authToken: try await AuthHelper.ensure(),
                                feedback: feedbackText)
                            
                            do {
                                let statusResponse = try await ChitChatHTTPSConnector.submitFeedback(request: submitFeedbackRequest)
                                
                                // TODO: Better HTTPS error reporting
                                if statusResponse.success != 0 {
                                    print("Received non-successful HTTPS response from server in FeedbackAlert... \(statusResponse.success)")
                                }
                            } catch {
                                // TODO: Handle errors
                                print("Error submitting feedback to server in FeedbackAlert... \(error)")
                            }
                        } catch {
                            // TODO: Handle errors
                            print("Error ensuring AuthToken in FeedbackAlert... \(error)")
                        }
                    }
                    
                    isPresented = false
                })
                
                Button("Cancel", role: .cancel, action: {
                    // Dismiss
                    isPresented = false
                })
            }) {
                Text("Please let us know what to improve.")
            }
    }
    
}

extension View {
    
    func feedbackAlert(isPresented: Binding<Bool>) -> some View {
        modifier(FeedbackAlert(isPresented: isPresented))
    }
    
}
