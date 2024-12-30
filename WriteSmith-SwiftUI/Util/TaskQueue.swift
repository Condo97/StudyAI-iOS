////
////  TaskQueue.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 12/27/24.
////
//
//import Foundation
//
///// An actor that manages a serial queue of asynchronous tasks.
//actor TaskQueue {
//    /// Holds a reference to the last enqueued task.
//    private var lastTask: Task<Void, Never>? = nil
//
//    /// Enqueues a new asynchronous operation to be executed serially.
//    /// - Parameter operation: The asynchronous operation to execute.
//    func enqueue(_ operation: @escaping () async -> Void) {
//        // Chain the new task to the last task to ensure serial execution.
//        lastTask = Task {
//            // Await the completion of the last task if it exists.
//            await lastTask?.value
//            // Execute the new operation.
//            await operation()
//        }
//    }
//}
