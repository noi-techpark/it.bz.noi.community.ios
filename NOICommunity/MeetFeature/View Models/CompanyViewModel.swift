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
import Core
import PeopleClient

// MARK - CompanyFilter

enum CompanyFilter: CaseIterable {

    case all
    case noiSpa
    case researchInstitutes
    case universities
    case institutions
    case companies
    case startup

    var title: String {
        switch self {
        case .all:
            .localized("filter_by_all")
        case .noiSpa:
            .localized("filter_by_noi_spa")
        case .researchInstitutes:
            .localized("filter_by_research_institutes")
        case .universities:
            .localized("filter_by_universities")
        case .institutions:
            .localized("filter_by_institutions")
        case .companies:
            .localized("filter_by_companies")
        case .startup:
            .localized("filter_by_startup")
        }
    }

    var tag: Company.Tag? {
        switch self {
        case .all:
            nil
        case .noiSpa:
            .noiCommunity
        case .researchInstitutes:
            nil
        case .universities:
            nil
        case .institutions:
            .researchInstitution
        case .companies:
            .company
        case .startup:
            .startup
        }
    }

}

// MARK: - CompanyViewModel

final class CompanyViewModel {
    
    let filterItems: [CompanyFilter] = CompanyFilter.allCases

    @Published private(set) var activeFilter: CompanyFilter = .all

    @Published private(set) var activeSearchTerm: String?

    @Published private(set) var results: (
        [Initial],
        [Initial: [CompanyId]]
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
        
        filterBy(searchTerm: activeSearchTerm, filter: activeFilter)
    }
    
    func company(withId companyId: String) -> Company? {
        guard let result = companyIdToCompany[companyId]
        else { fatalError("Unknown companyId: \(companyId)") }
        
        return result
    }

    func filterBy(
        searchTerm: String? = nil,
        filter: CompanyFilter? = nil
    ) {
        let searchTerm = searchTerm ?? activeSearchTerm
        let filter = filter ?? activeFilter

        activeSearchTerm = searchTerm
        activeFilter = filter

        let foo = companyIds
        // Maps company id to company
            .compactMap { self.company(withId: $0) }
        // Apply filtering based on tag
            .filter { company in
                guard let tag = filter.tag
                else { return true }

                return company.tags.contains(tag)
            }
        // Apply filtering based on search term
            .filter { company in
                guard let searchTerm,
                      !searchTerm.isEmpty
                else { return true }

                return company.name.localizedStandardContains(searchTerm)
            }
        // Sort alphabetically by name
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

        let filteredSortedCompanies = companyIds
            .lazy
            // Maps company id to company
            .compactMap { self.company(withId: $0) }
            // Apply filtering based on tag
            .filter { company in
                guard let tag = filter.tag
                else { return true }

                return company.tags.contains(tag)
            }
            // Apply filtering based on search term
            .filter { company in
                guard let searchTerm,
                      !searchTerm.isEmpty
                else { return true }

                return company.name.localizedStandardContains(searchTerm)
            }
            // Sort alphabetically by name
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

        let companiesIdsByInitial = Dictionary(
            grouping: filteredSortedCompanies,
            by: { Initial(from: $0.name) }
        )
            .mapValues { $0.map(\.id) }

        let initials = Array(Set(companiesIdsByInitial.keys)).sorted()
        self.results = (initials, companiesIdsByInitial)
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

    func filteredCompanies(withSearchTerm searchTerm: String?) -> [Company] {
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

        return Array(results)
    }

}
