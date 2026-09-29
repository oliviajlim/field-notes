//
//  FieldNote.swift
//  FieldNotes
//
//  Created by Olivia Lim on 9/29/26.
//

import AVKit
import Foundation
import SwiftUI

struct FieldNote: Identifiable {
    let id: UUID = UUID()
    let imagePath: String
    let audioPath: String
    let text: String

    init(imagePath: String, audioPath: String, text: String) {
        self.imagePath = imagePath
        self.audioPath = audioPath
        self.text = text
    }
}

