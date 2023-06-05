// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CompanyViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/05/22.
//

import Foundation
import Combine
import PeopleClient

// MARK: - CompanyViewModel

final class CompanyViewModel {
    
    private let allTags: [Company.Tag] = [.company, .startup, .researchInstitution]
    
    @Published private(set) var activeSearchTerm: String?
    
    @Published private(set) var results: (
        [Company.Tag],
        [Company.Tag: [CompanyId]]
    )!
    
    private var companyIds: [CompanyId]
    private var companyIdToCompany: [CompanyId: Company]
    
    private var fetchPeopleCancellable: AnyCancellable?
    
    var showDetailsHandler: ((Person, Any?) -> Void)!
    
    init(companies: [Company]) {
        companyIds = companies.map(\.id)
        companyIdToCompany = Dictionary(
            uniqueKeysWithValues: companies.map { ($0.id, $0) }
        )
        
        filter(searchTerm: activeSearchTerm)
    }
    
    func company(withId companyId: String) -> Company? {
        guard let result = companyIdToCompany[companyId]
        else { fatalError("Unknown companyId: \(companyId)") }
        
        return result
    }
    
    func filter(searchTerm: String?) {
        activeSearchTerm = searchTerm
        
        let tagToCompanyIds: [Company.Tag: [CompanyId]] = allTags
            .reduce([:]) { partialResult, tag in
                var result = partialResult
                let companyIds = self.companyIds(
                    searchTerm: searchTerm,
                    withTags: [tag]
                )
                if !companyIds.isEmpty {
                    result[tag] = companyIds
                }
                return result
            }
        let tags = allTags
            .filter { tagToCompanyIds[$0] != nil }
        self.results = (tags, tagToCompanyIds)
    }
    
}

// MARK: Private APIs

private extension CompanyViewModel {
    
    func companyIds(
        searchTerm: String?,
        withTags filterTags: Set<Company.Tag>
    ) -> [String] {
        let results = companyIds
            .lazy
            .compactMap { self.company(withId: $0) }
            .filter { company in
                // Search term predicate
                guard let searchTerm = searchTerm,
                      !searchTerm.isEmpty
                else { return true }

                return company.name.localizedStandardContains(searchTerm)
            }
            .filter { company in
                // Tags predicate
                for filterTag in filterTags {
                    if company.tags.contains(filterTag) {
                        return true
                    }
                }
                
                return false
            }
            .map(\.id)
        
        return Array(results)
    }
    
}
