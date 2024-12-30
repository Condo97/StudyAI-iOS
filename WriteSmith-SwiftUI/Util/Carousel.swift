//
//  Carousel.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/15/24.
//

import CoreData
import Foundation
import SwiftUI

struct Carousel<Content: View, FetchedResultsType: NSManagedObject & Identifiable>: View {
    
    @Binding var index: Int
    @FetchRequest var fetchRequest: FetchedResults<FetchedResultsType>
    var spacing: CGFloat// = 15
//    var trailingSpace: CGFloat// = 100
    var itemWidth: CGFloat
    var height: CGFloat// = 150
    @ViewBuilder var content: (FetchedResultsType) -> Content
    
    @GestureState private var offset: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { proxy in
//            let width = proxy.size.width - (trailingSpace - spacing)
//            let adjustMentWidth = (trailingSpace / 2)
            let width = itemWidth + spacing
            let trailingSpace = proxy.size.width - itemWidth
            let adjustmentWidth = trailingSpace / 2
            
            HStack(spacing: spacing) {
                ForEach(fetchRequest) { item in
                    content(item)
                        .frame(width: itemWidth/*proxy.size.width - trailingSpace*/, height: height)
                }
            }
//            .padding(.horizontal, spacing)
            .offset(x: calculateOffset(width: width, adjustmentWidth: adjustmentWidth, trailingSpace: trailingSpace))
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), fetchRequest.count - 1), 0)
                        withAnimation {
                            index = currentIndex
                        }
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), fetchRequest.count - 1), 0)
                    })
            )
        }
        .frame(height: height)
        .clipped()
        .animation(.easeInOut, value: offset == 0)
        .onAppear {
            currentIndex = index
        }
    }
    
    private func calculateOffset(width: CGFloat, adjustmentWidth: CGFloat, trailingSpace: CGFloat) -> CGFloat {
        var totalOffset = (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustmentWidth : 0) + offset
        if currentIndex == 0 {
            totalOffset += (trailingSpace / 2)
        }
        return totalOffset
    }
    
}
