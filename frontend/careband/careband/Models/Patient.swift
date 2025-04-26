//
//  Patient.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import Foundation


struct Patient: Codable, Identifiable, Hashable {
    var id: String { uuid }
    
    let uuid: String
    let name: String
    let dob: Date
    let ssn: String
    let allergies: [String]
    let history: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uuid = try container.decode(String.self, forKey: .uuid)
        name = try container.decode(String.self, forKey: .name)
        dob = try container.decode(Date.self, forKey: .dob)
        ssn = try container.decode(String.self, forKey: .ssn)
        history = try container.decode(String.self, forKey: .history)

        if let allergiesString = try? container.decode(String.self, forKey: .allergies) {
            // 🔥 Deduplicate here while parsing
            let split = allergiesString
                .split(separator: ";")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            allergies = Array(Set(split)) // <-- deduplicate here
        } else {
            allergies = try container.decode([String].self, forKey: .allergies)
        }
    }
}
