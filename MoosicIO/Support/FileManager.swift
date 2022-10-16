//
//  FileManager.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 16.10.2022.
//

import Foundation

protocol MoosicFileManager {
    func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL
    func fileExists(atPath path: String) -> Bool
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]?) -> Bool
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws
}

extension FileManager: MoosicFileManager {}

protocol MoosicNotificationCenter {
    func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Swift.Void) -> NSObjectProtocol
    func removeObserver(_ observer: Any)
}

extension NotificationCenter: MoosicNotificationCenter {}
