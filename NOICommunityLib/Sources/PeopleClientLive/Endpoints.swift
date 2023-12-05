// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoints.swift
//  ArticlesClientLive
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import Core

extension Endpoint {
    
    static func accounts() -> Endpoint {
        Self(path: "/accounts") {
            URLQueryItem(
                name: "$filter",
                value: "Microsoft.Dynamics.CRM.ContainValues(PropertyName=@p1,PropertyValues=@p2) and statuscode eq 1"
            )
            
            URLQueryItem(
                name: "@p1",
                value: "'crb14_accountcat_placepresscommunity'"
            )
            
            URLQueryItem(
                name: "@p2",
                value: "['952210000']"
            )
            
            URLQueryItem(
                name: "$select",
                value: "name,noi_nameit,telephone1,address1_composite,crb14_accountcat_placepresscommunity"
            )
            
            URLQueryItem(
                name: "$count",
                value: "true"
            )
        }
    }
    
    static func contacts() -> Endpoint {
        Self(path: "/contacts") {
            URLQueryItem(
                name: "$filter",
                value: "Microsoft.Dynamics.CRM.ContainValues(PropertyName=@p1,PropertyValues=@p2) and statuscode eq 1"
            )
            
            URLQueryItem(
                name: "@p1",
                value: "'noi_contactcat_placepresscommunity'"
            )
            
            URLQueryItem(
                name: "@p2",
                value: "['181640000']"
            )
            
            URLQueryItem(
                name: "$select",
                value: "emailaddress1,firstname,lastname,fullname,_parentcustomerid_value"
            )
            
            URLQueryItem(
                name: "$orderby",
                value: "fullname"
            )
        }
    }
    
}
