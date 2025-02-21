//
//  ViewModelDelegateMock.swift
//  LWWElementDictionaryTests
//
//  Created by Mena Gamal on 21/02/2025.
//

import Foundation
@testable import LWWElementDictionary

final class ViewModelDelegateMock: ViewModelDelegate {
    var onUpdate: (() -> Void)?

    func didUpdateData() {
        onUpdate?()
    }
}
