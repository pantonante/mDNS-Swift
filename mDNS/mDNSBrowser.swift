//
//  mDNSBrowser.swift
//  mDNS
//
//  Created by Pasquale Antonante on 14/05/16.
//  Copyright © 2016 Pasquale Antonante. All rights reserved.
//

import Foundation

class mDNSBrowser : NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    let beacubeType:String
    var beacubeBrowser:NSNetServiceBrowser
    var serviceList:[NSNetService]
    var beacubeList:[BeacubeService]

    override init(){
        self.beacubeType = "_beacube._tcp."
        self.beacubeBrowser = NSNetServiceBrowser()
        self.serviceList = [NSNetService]()
        self.beacubeList = [BeacubeService]()
        
        super.init()
        self.beacubeBrowser.delegate = self
    }

    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("mDNS browsing commencing...")
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        serviceList.append(aNetService)
        print("Found: \(aNetService)")
        if !moreComing {
            update()
        }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Search was not successful. Error code: \(errorDict[NSNetServicesErrorCode])")
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        let iService = serviceList.indexOf(aNetService)
        if iService != nil {
            serviceList.removeAtIndex(iService!)
        }
        let subArray = beacubeList.filter({$0.netService == aNetService})
        for item in subArray {
            let iBeacubeList = beacubeList.indexOf(item)
            if iBeacubeList != nil {
                beacubeList.removeAtIndex(iBeacubeList!)
            }
        }
        print("Became unavailable: \(aNetService)")
        if !moreComing {
            update()
        }
    }
    
    func update() {
        for service in serviceList {
            service.delegate = self
            service.resolveWithTimeout(5)
        }
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        //service.addresses - array containing NSData objects, each of which contains an appropriate
        //sockaddr structure that you can use to connect to the socket
        for addressBytes in sender.addresses!
        {
            var inetAddress : sockaddr_in!
            var inetAddress6 : sockaddr_in6?
            //NSData’s bytes returns a read-only pointer (const void *) to the receiver’s contents.
            //var bytes: UnsafePointer<()> { get }
            let inetAddressPointer = UnsafePointer<sockaddr_in>(addressBytes.bytes)
            //Access the underlying raw memory
            inetAddress = inetAddressPointer.memory
            
            if inetAddress.sin_family == __uint8_t(AF_INET) //Note: explicit convertion (var AF_INET: Int32 { get } /* internetwork: UDP, TCP, etc. */)
            {
            }
            else
            {
                if inetAddress.sin_family == __uint8_t(AF_INET6) //var AF_INET6: Int32 { get } /* IPv6 */
                {
                    let inetAddressPointer6 = UnsafePointer<sockaddr_in6>(addressBytes.bytes)
                    inetAddress6 = inetAddressPointer6.memory
                    inetAddress = nil
                }
                else
                {
                    inetAddress = nil
                }
            }
            var ipString : UnsafePointer<Int8>?
            //static func alloc(num: Int) -> UnsafeMutablePointer<T>
            let ipStringBuffer = UnsafeMutablePointer<Int8>.alloc(Int(INET6_ADDRSTRLEN))
            if (inetAddress != nil)
            {
                var addr = inetAddress.sin_addr
                ///func inet_ntop(_: Int32, _: UnsafePointer<()>, _: UnsafeMutablePointer<Int8>, _: socklen_t) -> UnsafePointer<Int8>
                ipString = inet_ntop(Int32(inetAddress.sin_family),
                                     &addr,
                                     ipStringBuffer,
                                     __uint32_t(INET6_ADDRSTRLEN))
            }
            else
            {
                if (inetAddress6 != nil)
                {
                    var addr  = inetAddress6!.sin6_addr
                    
                    ipString = inet_ntop(Int32(inetAddress6!.sin6_family),
                                         &addr,
                                         ipStringBuffer,
                                         __uint32_t(INET6_ADDRSTRLEN))
                }
            }
            if (ipString != nil)
            {
                // Returns `nil` if the `CString` is `NULL` or if it contains ill-formed
                // UTF-8 code unit sequences.
                //static func fromCString(cs: UnsafePointer<CChar>) -> String?
                let ip = String.fromCString(ipString!)
                if ip != nil {
                    print("[NEW] \(sender.name)(\(sender.type)) - \(ip!)")
                    beacubeList.append(BeacubeService(netService: sender, ipAddress: ip!))
                    NSNotificationCenter.defaultCenter().postNotificationName("newBeacubeServiceDiscovered", object: self)
                }
            }
            /// This type stores a pointer to an object of type T. It provides no
            /// automated memory management, and therefore the user must take care
            /// to allocate and free memory appropriately.
            ipStringBuffer.dealloc(Int(INET6_ADDRSTRLEN))
        }
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("\(sender.name) did not resolve: \(errorDict[NSNetServicesErrorCode]!)")
    }
    
    func searchForServices() {
        self.beacubeBrowser.searchForServicesOfType(self.beacubeType, inDomain: "")
    }
    
    func reset() {
        self.beacubeBrowser.stop()
        for service in serviceList {
            service.stop()
        }
        serviceList.removeAll()
        beacubeList.removeAll()
    }

}