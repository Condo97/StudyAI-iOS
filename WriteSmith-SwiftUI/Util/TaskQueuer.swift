////
////  TaskQueuer.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 12/27/24.
////
//
//import Foundation
//
///// A class that manages enqueuing processing tasks through TaskQueue.
//class TaskQueuer: ObservableObject {
////    /// Instance of TaskQueue to manage serial task execution.
////    private let taskQueue = TaskQueue()
//    private let channel = AsyncChannel
//
//    /// Enqueues the `process` function to be executed serially.
//    func enqueueProcess(process: @escaping () async -> Void) {
//        Task {
//            await taskQueue.enqueue {
//                await process()
//            }
//        }
//    }
//    
//}
