//
//  FormatTime.swift
//  page_Control
//
//  Created by poan on 2023/5/10.
//

import Foundation

class FormatTime {
    // 將秒數轉換成時分秒格式
    static func formatTime(_ timeInSeconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInSeconds) ?? "00:00:00"
    }
}
