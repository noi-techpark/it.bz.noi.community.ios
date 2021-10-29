//
//  URL+KnowNOIURLs.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

extension URL {
    static let map = URL(string: .localized("url_map"))!
    static let roomBooking = URL(string: .localized("url_room_booking"))!
    static let companies = URL(string: .localized("url_companies"))!
    static let startups = URL(string: .localized("url_startups"))!
    static let university = URL(string: .localized("url_university"))!
    static let research = URL(string: .localized("url_research"))!
    static let institutions = URL(string: .localized("url_institutions"))!
    static let lab = URL(string: .localized("url_lab"))!
    static let aboutUs = URL(string: .localized("url_about_us"))!
    static let onboarding = URL(string: .localized("url_onboarding"))!
    static let feedbacks = URL(string: .localized("url_provide_feedback"))!
    static let noisteriaMenu = URL(string: .localized("url_noisteria_menu"))!
    static let noiBarMenu = URL(string: .localized("url_noi_bar_menu"))!
    static let alumixMenu = URL(string: .localized("url_alumix_menu"))!

    static let alumixImageURL = Bundle.restaurants.url(
        forResource:"alumix",
        withExtension: ".jpg"
    )!

    static let alumixFritturaImageURL = Bundle.restaurants.url(
        forResource:"alumix_frittura",
        withExtension: ".jpg"
    )!

    static let alumixPizzaImageURL = Bundle.restaurants.url(
        forResource:"alumix_pizza",
        withExtension: ".jpg"
    )!

    static let alumixSalagardenImageURL = Bundle.restaurants.url(
        forResource:"alumix_sala-garden",
        withExtension: ".jpg"
    )!

    static let noisteriaaußenImageURL = Bundle.restaurants.url(
        forResource:"noisteria_außen",
        withExtension: ".jpg"
    )!

    static let noisteriaBarImageURL = Bundle.restaurants.url(
        forResource:"noisteria_bar",
        withExtension: ".jpg"
    )!

    static let noisteriaInnenImageURL = Bundle.restaurants.url(
        forResource:"noisteria_innen",
        withExtension: ".jpg"
    )!

    static let noisteriaInnen2ImageURL = Bundle.restaurants.url(
        forResource:"noisteria_innen2",
        withExtension: ".jpg"
    )!

    static let noisteriaSaladImageURL = Bundle.restaurants.url(
        forResource:"noisteria_salad",
        withExtension: ".jpg"
    )!

    static let rockinBeetsAsparagiLasagneImageURL = Bundle.restaurants.url(
        forResource: "rockin beets_asparagi_lasagne",
        withExtension: ".jpg"
    )!

    static let rockinBeetsMealPrepImageURL = Bundle.restaurants.url(
        forResource:"rockin beets_meal prep",
        withExtension: ".jpg"
    )!

    static let rockinBeetsMealsImageURL = Bundle.restaurants.url(
        forResource:"rockin beets_meals",
        withExtension: ".jpg"
    )!

    static let rockinBeetsObstmarktImageURL = Bundle.restaurants.url(
        forResource: "rockin beets_obstmarkt",
        withExtension: ".jpg"
    )!
}

private extension Bundle {
    static let restaurants: Bundle = {
        let restaurantsBundleURL = Bundle.main.url(
            forResource: "Restaurants",
            withExtension: "bundle"
        )!
        return Bundle(url: restaurantsBundleURL)!
    }()
}
