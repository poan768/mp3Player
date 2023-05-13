//
//  Alblum.swift
//  page_Control
//
//  Created by poan on 2023/5/9.
//

import Foundation

struct Album {
    let singer: String
    let singTitle: String
}

class TotalAlbum{
    // 使用歌名抓取 歌手專輯
    func getAlbum(singer: String) -> (album: [Album], index: Int) {
        switch singer{
        case "陳勢安":
            return (album: 陳勢安, index: 0)
        case "周杰倫":
            return (album: 周杰倫, index: 1)
        case "黃鴻升":
            return (album: 黃鴻升, index: 2)
        default:
            return (album: 陳勢安, index: 0)
        }
    }
    
    // 用index抓取 歌手專輯
    func getAlbum(index: Int) -> [Album] {
        switch index{
        case 0:
            return 陳勢安
        case 1:
            return 周杰倫
        case 2:
            return 黃鴻升
        default:
            return 陳勢安
        }
    }
    
    let 陳勢安: [Album] = [
        Album(singer: "陳勢安", singTitle: "天后"),
        Album(singer: "陳勢安", singTitle: "勢在必行")
    ]
    
    let 周杰倫: [Album] = [
        Album(singer: "周杰倫", singTitle: "一路向北"),
        Album(singer: "周杰倫", singTitle: "給我一首歌的時間"),
        Album(singer: "周杰倫", singTitle: "告白氣球")
    ]
    
    let 黃鴻升: [Album] = [
        Album(singer: "黃鴻升", singTitle: "地球上最浪漫的一首歌"),
        Album(singer: "黃鴻升", singTitle: "有感情歌"),
        Album(singer: "黃鴻升", singTitle: "超有感")
    ]
}
