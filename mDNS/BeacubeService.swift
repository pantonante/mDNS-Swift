//
//  BeacubeService.swift
//  mDNS
//
//  Created by Pasquale Antonante on 14/05/16.
//  Copyright © 2016 Pasquale Antonante. All rights reserved.
//

import Foundation

class BeacubeService:Equatable{
    var netService:NSNetService
    var ipAddress:String
    
    init(netService:NSNetService, ipAddress:String) {
        self.netService = netService
        self.ipAddress = ipAddress
    }
    
    func getAddress() -> String {
        return ipAddress
    }

}

func == (lhs: BeacubeService, rhs: BeacubeService) -> Bool {
    return (lhs.netService == rhs.netService) && (lhs.ipAddress == rhs.ipAddress)
}