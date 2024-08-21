// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  PeopleViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/05/22.
//

import Foundation
import Combine
import Core
import PeopleClient
import AuthClient

// MARK: - PeopleViewModel

final class PeopleViewModel {
    
    let authClient: AuthClient
    let peopleClient: PeopleClient
    
    @Published private(set) var isLoading = false
    
    @Published private(set) var error: Error!
    
    @Published private(set) var numberOfResults = 0
    
    @Published private(set) var peopleIds: [PersonId]!
    
    @Published private(set) var results: (
        [Initial],
        [Initial: [PersonId]]
    )!
    
    @Published private(set) var activeSearchTerm: String?
    
    @Published private(set) var activeCompanyIdsFilter: Set<CompanyId>? {
        didSet {
            updatedCompanyIdsFilter = Array(oldValue ?? []) + Array(activeCompanyIdsFilter ?? [])
        }
    }
    
    @Published private(set) var updatedCompanyIdsFilter: [CompanyId] = []
    
    private var personIdToPerson: [PersonId: Person] = [:]
    
    private var companyIds: [CompanyId]?
    private var companyIdToCompany: [CompanyId : Company]?
    
    private var fetchPeopleCancellable: AnyCancellable?
    
    var showDetailsHandler: ((Person, Any?) -> Void)!
    
    var showFiltersHandler: ((Any?) -> Void)!
    
    var showFilteredResultsHandler: (() -> Void)!
    
    init(authClient: AuthClient, peopleClient: PeopleClient) {
        self.authClient = authClient
        self.peopleClient = peopleClient
    }
    
    func fetchPeople() {
        let companiesPublisher: AnyPublisher<([CompanyId], [CompanyId: Company]), Error>
        if let companyIds = companyIds,
           let companyIdToCompany = companyIdToCompany {
            companiesPublisher = Just((companyIds, companyIdToCompany))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            let authenticatedCompaniesPublisher = authClient.accessToken()
                .flatMap { [peopleClient] accessToken in
                    peopleClient.companies(accessToken)
                }
            companiesPublisher = authenticatedCompaniesPublisher
                .map { companies in
                    let companyIds = companies.map(\.id)
                    let companyIdToCompany = Dictionary(
                        uniqueKeysWithValues: companies.map { ($0.id, $0) }
                    )
                    return (companyIds, companyIdToCompany)
                }
                .eraseToAnyPublisher()
        }
        
        let peoplePublisher = authClient.accessToken()
            .flatMap { [peopleClient] accessToken in
                peopleClient.people(accessToken)
            }
        
        isLoading = true
        
        fetchPeopleCancellable = companiesPublisher
            .zip(peoplePublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] (companyResult, people) in
                    guard let self = self
                    else { return }
                    
                    let (companyIds, companyIdToCompany) = companyResult
                    self.companyIds = companyIds
                    self.companyIdToCompany = companyIdToCompany
                    self.personIdToPerson = Dictionary(
                        uniqueKeysWithValues: people.map { ($0.id, $0) }
                    )
                    self.peopleIds = people.map(\.id)
                    self.filter(
                        searchTerm: self.activeSearchTerm,
                        companyIds: self.activeCompanyIdsFilter
                    )
                })
    }
    
    func person(withId personId: PersonId) -> Person {
        guard let result = personIdToPerson[personId]
        else { fatalError("Unknown personId: \(personId)") }
        
        return result
    }
    
    func company(withId companyId: CompanyId) -> Company? {
        companyIdToCompany?[companyId]
    }
    
    func showPersonDetails(of personId: PersonId, sender: Any?) {
        showDetailsHandler(person(withId: personId), sender)
    }
    
    func showFilter(sender: Any?) {
        showFiltersHandler(sender)
    }
    
    func filter(
        searchTerm: String?,
        companyIds filterCompanyIds: Set<CompanyId>?
    ) {
        activeSearchTerm = searchTerm
        activeCompanyIdsFilter = filterCompanyIds
        
        let filteredSortedPeople = peopleIds
            .lazy
            // Maps person id to person
            .map { self.person(withId: $0) }
            // Apply filtering based on search term
            .filter { person in
                guard let searchTerm,
                      !searchTerm.isEmpty
                else { return true }

                return person.fullname.localizedStandardContains(searchTerm)
            }
            // Apply filtering based on company filters
            .filter { person in
                // Belong to company predicate (OR)
                guard let filterCompanyIds = filterCompanyIds
                else { return true }
                
                guard let companyId = person.companyId
                else { return false }
                
                return filterCompanyIds.contains(companyId)
            }
            // Sort alphabetically by name
            .sorted {
                $0.fullname.localizedCaseInsensitiveCompare($1.fullname) == .orderedAscending
            }

        let peopleIdsByInitial = Dictionary(
            grouping: filteredSortedPeople,
            by: { Initial(from: $0.fullname) }
        )
            .mapValues { $0.map(\.id) }

        let initials = Array(Set(peopleIdsByInitial.keys)).sorted()
        self.results = (initials, peopleIdsByInitial)
    }
    
    func makeCompanyViewModel() -> CompanyViewModel {
        let companies: [Company]
        
        if let companyIds = companyIds {
            companies = companyIds.compactMap { self.company(withId: $0) }
        } else {
            companies = []
        }
        
        return .init(companies: companies)
    }
    
    func clearActiveFilters() {
        filter(searchTerm: activeSearchTerm, companyIds: nil)
    }
    
    func showFilteredResults() {
        showFilteredResultsHandler()
    }
    
}
