//
//  BinPackingAlgorythm.swift
//   AROrganizer-Develop
//
//  Created by Valeriy Jefimov on 6/10/22.
//

import UIKit

// MARK: - Items
struct PackableItem: Hashable {
    var id: UUID
    var isRotated: Bool = false
    var width: Float
    var height: Float
    var x: Float = 0
    var y: Float = 0
}

extension PackableItem {
    var area: Float { self.width * self.height }
    
    mutating func rotate() {
        let h = self.height
        let w = self.width
        self.width = h
        self.height = w
        self.isRotated.toggle()
    }
}

// MARK: - Packer
enum BinAlgo: CaseIterable {
    case bestFit
    case firstFit
}

enum Heuristic: String, CaseIterable {
    case bestArea
    case bestShortside
    case bestLongside
    case worstArea
    case worstShortside
    case worstLongside
    case bottomLeft
    
    static var allCases: [Heuristic] {
        return [
            .bestArea,
            // .bestShortside,
            .bestLongside,
            // .worstArea,
            // .worstShortside,
            // .worstLongside,
            .bottomLeft
        ]
    }
    
    static var `default`: Heuristic {
        return .bottomLeft
    }
}

typealias ItemPackerResult = (fittedItems: [PackableItem], overlappedItems: [PackableItem])

enum ItemPackError: Error {
    case general
    case nothingToPack
    case itemTooBig(PackableItem)
}

final class BoxPacker {
    private var binWidth: Float
    private var binHeight: Float
    private var binAlgo: BinAlgo = .firstFit
    private var heuristic: Heuristic
    private var rotation: Bool = true
    private var sorting: Bool = true
    private var items: [PackableItem]
    private var bins: [MaximalRectangleAlgo]
    
    init(size: (width: Float, height: Float), items: [PackableItem] = []) {
        self.heuristic = Heuristic(rawValue: UserDefaults.autosortType) ?? .default
        self.binWidth = size.width
        self.binHeight = size.height
        self.items = items
        
        let bin = MaximalRectangleAlgo(
            x: binWidth,
            y: binHeight,
            rotation: rotation,
            heuristic: heuristic)
        self.bins = [bin]
        
        if sorting {
            itemSort()
        }
    }
    
    init(
        xAxisLength: Float = 8,
        yAxisLength: Float = 4,
        binAlgo: BinAlgo = .firstFit,
        heuristic: Heuristic = .bottomLeft,
        rotation: Bool = false,
        sorting: Bool = true,
        items: [PackableItem] = []
    ) {
        self.binWidth = xAxisLength
        self.binHeight = yAxisLength
        self.binAlgo = binAlgo
        self.heuristic = heuristic
        self.rotation = rotation
        self.sorting = sorting
        self.items = items
        
        let bin = MaximalRectangleAlgo(
            x: binWidth,
            y: binHeight,
            rotation: rotation,
            heuristic: heuristic)
        self.bins = [bin]
        
        if sorting {
            itemSort()
        }
    }
    
    func pack(completion: (Result<ItemPackerResult, ItemPackError>) -> Void) {
        do {
            for item in items {
                try binSelAlgo(item: item)
            }
            guard let fittedItems = bins.first?.items, !fittedItems.isEmpty else {
                throw ItemPackError.nothingToPack
            }
            bins.removeFirst()
            let overlappedItems = bins.flatMap(\.items)
            completion(.success((fittedItems, overlappedItems)))
        } catch let error {
            completion(.failure((error as? ItemPackError) ?? .general))
        }
    }
}

private extension BoxPacker {
    func binSelAlgo(item: PackableItem) throws {
        switch self.binAlgo {
        case .bestFit:
            try insertBestFit(item: item)
        case .firstFit:
            insertFirstFit(item: item)
        }
    }
    
    /// Insert into the first bin that fits the item
    func insertFirstFit(item: PackableItem) {
        var result = false
        for bin in bins {
            result = bin.insert(item: item, heuristic: self.heuristic)
            if result { break }
        }
        
        if !result {
            bins.append(
                MaximalRectangleAlgo(
                    x: binWidth,
                    y: binHeight,
                    rotation: rotation,
                    heuristic: heuristic)
            )
            _ = bins.last?.insert(item: item, heuristic: self.heuristic)
        }
    }
    
    /// Insert into the bin that best fits the item
    func insertBestFit(item: PackableItem) throws {
        var itemFits = false
        if item.width <= self.binWidth &&
            item.height <= self.binHeight {
            itemFits = true
        }
        if self.rotation &&
            item.height <= self.binWidth &&
            item.width <= self.binHeight {
            itemFits = true
        }
        
        if !itemFits {
            throw ItemPackError.itemTooBig(item)
        }
        
        typealias Score = ((Float, Float), MaximalRectangleAlgo)
        var scores = [Score]()
        for bin in bins {
            if let s = bin.findBestScore(item: item).0 {
                scores.append((s, bin))
            }
        }
        
        if !scores.isEmpty {
            let minScore = scores.min { o1, o2 in
                return o1.0 < o2.0
            }
            _ = minScore?.1.insert(item: item, heuristic: self.heuristic)
            return
        }
        
        let newBin = MaximalRectangleAlgo(
            x: binWidth,
            y: binHeight,
            rotation: rotation,
            heuristic: heuristic)
        _ = newBin.insert(item: item, heuristic: self.heuristic)
        bins.append(newBin)
    }
    
    func itemSort() {
        items.sort(by: { leftItem, rightItem in
            leftItem.height * leftItem.width <
                rightItem.height * rightItem.width
        })
    }
}

// MARK: - Algo
private struct FreeRectangle: Equatable {
    var width: Float
    var height: Float
    let x: Float
    let y: Float
    
    var area: Float { self.width * self.height }
}

private class MaximalRectangleAlgo {
    
    // MARK: - Private
    private var x: Float
    private var y: Float
    private var rotation: Bool
    private var area: Float
    private var freeArea: Float
    private var heuristic: Heuristic
    private var freeRects: [FreeRectangle]
    private var score: (_ rect: FreeRectangle, _ item: PackableItem) -> (Float, Float)
    
    // MARK: - Piblic
    public var items: [PackableItem]
    
    init(
        x: Float = 8,
        y: Float = 4,
        rotation: Bool = true,
        heuristic: Heuristic = .bottomLeft
    ) {
        self.heuristic = heuristic
        self.x = x
        self.y = y
        self.rotation = rotation
        self.items = []
        self.area = x * y
        self.freeArea = self.area
        
        switch heuristic {
        case .bottomLeft:
            self.score = { rect, item in
                return (rect.y + item.height, rect.x)
            }
        case .bestArea:
            self.score = { rect, item in
                return (
                    rect.area - item.area,
                    min(rect.width - item.width,
                        rect.height - item.height)
                )
            }
        case .bestShortside:
            self.score = { rect, item in
                return (
                    min(rect.width - item.width,
                        rect.height - item.height),
                    max(rect.width - item.width,
                        rect.height - item.height)
                )
            }
        case .bestLongside:
            self.score = { rect, item in
                return (
                    max(rect.width - item.width,
                        rect.height - item.height),
                    min(rect.width - item.width,
                        rect.height - item.height)
                )
            }
        case .worstArea:
            self.score = { rect, item in
                return (
                    0 - (rect.area - item.area),
                    0 - min(rect.width - item.width,
                            rect.height - item.height)
                )
            }
        case .worstShortside:
            self.score = { rect, item in
                return (
                    0 - min(rect.width - item.width,
                            rect.height - item.height),
                    0 - max(rect.width - item.width,
                            rect.height - item.height)
                )
            }
        case .worstLongside:
            self.score = { rect, item in
                return (
                    0 - max(rect.width - item.width,
                            rect.height - item.height),
                    0 - min(rect.width - item.width,
                            rect.height - item.height)
                )
            }
        }
        
        if x == 0 || y == 0 {
            self.freeRects = []
        } else {
            self.freeRects = [
                .init(width: x,
                      height: y,
                      x: 0,
                      y: 0)
            ]
        }
    }
    
    /// Remove all FreeRectangles full encapsulated inside another FreeRectangle.
    func removeRedundent() -> [FreeRectangle] {
        var i = 0
        while i < self.freeRects.count {
            var j = i + 1
            while j < self.freeRects.count {
                if encapsulates(F0: freeRects[j],
                                F1: freeRects[i]) {
                    freeRects.remove(at: i)
                    i -= 1
                    break
                }
                if encapsulates(F0: freeRects[i],
                                F1: freeRects[j]) {
                    freeRects.remove(at: j)
                    j -= 1
                }
                j += 1
            }
            i += 1
        }
        return self.freeRects
    }
    
    ///  Loop through all FreeRectangles and prune any overlapping the itemBounds
    func pruneOverlaps(itemBounds: Tuple) {
        var result = [FreeRectangle]()
        for rect in freeRects {
            if checkIntersection(freeRect: rect, box: itemBounds) {
                let overlap = findOverlap(freeRect: rect, box: itemBounds)
                let newRects = clipOverlap(rect: rect, overlap: overlap)
                result.append(contentsOf: newRects)
            } else {
                result.append(rect)
            }
        }
        self.freeRects = result
        _ = removeRedundent()
    }
    
    typealias FindBestScoreTuple = ((Float, Float)?, FreeRectangle?, Bool)
    func findBestScore(item: PackableItem) -> FindBestScoreTuple {
        var rects = [((Float, Float), FreeRectangle, Bool)]()
        for rect in freeRects {
            if itemFitsRect(item: item, rect: rect) {
                rects.append((score(rect, item), rect, false))
                
            }
            if itemFitsRect(item: item, rect: rect, rotation: rotation) {
                rects.append((score(rect, item), rect, true))
            }
        }
        
        guard let min = rects.min(by: { o1, o2 in
            o1.0 < o2.0
        }) else { return (nil, nil, false) }
        return min
    }
    
    /// Public method for selecting heuristic and inserting item
    func insert(item: PackableItem, heuristic: Heuristic) -> Bool {
        let bestScore = findBestScore(item: item)
        let bestRect = bestScore.1
        let rotated = bestScore.2
        var mutableItem = item
        
        if let bestRect = bestRect {
            if rotated {
                mutableItem.rotate()
            }
            mutableItem.x = bestRect.x
            mutableItem.y = bestRect.y
            items.append(mutableItem)
            
            self.freeArea -= item.area
            let maximals = splitRectangle(rectangle: bestRect, item: item)
            freeRects.removeAll(where: {
                $0 == bestRect
            })
            
            freeRects.append(contentsOf: maximals)
            let itemBounds = itemBounds(item: item)
            pruneOverlaps(itemBounds: itemBounds)
            return true
        }
        
        return false
    }
}

private func itemFitsRect(item: PackableItem,
                          rect: FreeRectangle,
                          rotation: Bool = false) -> Bool {
    if (!rotation &&
        item.width <= rect.width &&
        item.height <= rect.height) ||
        (rotation &&
         item.height <= rect.width &&
         item.width <= rect.height) {
        return true
    }
    return false
}

private func splitRectangle(rectangle: FreeRectangle,
                            item: PackableItem) -> [FreeRectangle] {
    // Return a list of maximal free rectangles from a split
    var results = [FreeRectangle]()
    if item.width < rectangle.width {
        let Fw = rectangle.width - item.width
        let Fh = rectangle.height
        let Fx = rectangle.x + item.width
        let Fy = rectangle.y
        results.append(.init(width: Fw, height: Fh, x: Fx, y: Fy))
    }
    
    if item.height < rectangle.height {
        let Fw = rectangle.width
        let Fh = rectangle.height - item.height
        let Fx = rectangle.x
        let Fy = rectangle.y + item.height
        results.append(.init(width: Fw, height: Fh, x: Fx, y: Fy))
    }
    
    return results
}

typealias Tuple = (Float, Float, Float, Float)

private func itemBounds(item: PackableItem) -> Tuple {
    // Returns the lower left and upper right
    // corners of the item's bounding box.
    
    return (item.x,
            item.y,
            item.x + item.width,
            item.y + item.height)
}

/// Checks if bounding box intersects rectangle
private func checkIntersection(freeRect: FreeRectangle, box: Tuple) -> Bool {
    if box.0 >= freeRect.x + freeRect.width ||
        box.2 <= freeRect.x ||
        box.1 >= freeRect.y + freeRect.height ||
        box.3 <= freeRect.y {
        return false
    }
    return true
}

///  returns the bottom left and top right
///  coordinates of the overlap
private func findOverlap(freeRect: FreeRectangle, box: Tuple) -> Tuple {
    
    let x1 = freeRect.x
    let y1 = freeRect.y
    let x2 = freeRect.x + freeRect.width
    let y2 = freeRect.y + freeRect.height
    let x3 = box.0
    let y3 = box.1
    let x4 = box.2
    let y4 = box.3
    
    let x5 = max(x1, x3)
    let y5 = max(y1, y3)
    let x6 = min(x2, x4)
    let y6 = min(y2, y4)
    
    return (x5, y5, x6, y6)
}

/// Return maximal rectangles for  non-intersected
/// parts of rect.
private func clipOverlap(rect: FreeRectangle, overlap: Tuple) -> [FreeRectangle] {
    let Fx = rect.x
    let Fy = rect.y
    let Fw = rect.width
    let Fh = rect.height
    let Ox1 = overlap.0
    let Oy1 = overlap.1
    let Ox2 = overlap.2
    let Oy2 = overlap.3
    
    var results = [FreeRectangle]()
    
    // Check for non-intersected sections
    // Left Side
    if Ox1 > Fx {
        results.append(
            FreeRectangle(width: Ox1 - Fx,
                          height: Fh,
                          x: Fx,
                          y: Fy)
        )
    }
    // Right side
    if Ox2 < Fx + Fw {
        results.append(
            FreeRectangle(width: Fx + Fw - Ox2,
                          height: Fh,
                          x: Ox2,
                          y: Fy)
        )
    }
    // Bottom Side
    if Oy1 > Fy {
        results.append(
            FreeRectangle(
                width: Fw,
                height: Oy1 - Fy,
                x: Fx,
                y: Fy)
        )
    }
    // Top Side
    if Oy2 < Fy + Fh {
        results.append(
            FreeRectangle(width: Fw,
                          height: Fy + Fh - Oy2,
                          x: Fx,
                          y: Oy2)
        )
    }
    
    return results
}

///  Returns true if F1 is fully encapsulate inside F0
private func encapsulates(F0: FreeRectangle,
                          F1: FreeRectangle) -> Bool {
    if F1.x < F0.x || F1.x > F0.x + F0.width {
        return false
    }
    if F1.x + F1.width > F0.x + F0.width {
        return false
    }
    
    if F1.y < F0.y || F1.y > F0.y + F0.height {
        return false
    }
    if F1.y + F1.height > F0.y + F0.height {
        return false
    }
    
    return true
    
}

extension BinAlgo {
    var title: String {
        switch self {
        case .bestFit:
            return "bestFit"
        case .firstFit:
            return "firstFit"
        }
    }
}
