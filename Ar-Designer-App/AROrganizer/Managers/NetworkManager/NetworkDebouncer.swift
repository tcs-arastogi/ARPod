//
//  NetworkDebouncer.swift
//  AROrganizer
//
//  Created by Mykhailo Lysenko on 7/7/22.
//

import Foundation

final class NetworkDebouncer {
    var callback: (() -> Void)
        var delay: Double
        weak var timer: Timer?

    init(delay: Double = 3.0, callback: @escaping (() -> Void)) {
        self.delay = delay
        self.callback = callback
    }

    func call() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self,
                                             selector: #selector(NetworkDebouncer.fireNow),
                                             userInfo: nil, repeats: false)
        timer = nextTimer
    }

    @IBAction func fireNow() {
        callback()
    }
}
