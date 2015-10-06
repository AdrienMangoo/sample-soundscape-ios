//
//  BLEDiscoveryProvider.swift
//  MSF
//
//  Created by ANDRES ORTEGA PENA on 10/7/14.
//  Copyright (c) 2014 Samsung. All rights reserved.
//

//import UIKit
import CoreBluetooth



struct BLEReadControlData {
    var id = ""
    var outBuf = NSMutableData()
    var gotHeader = false
    var messageLen: Int = 0
}

class BLEDiscoveryProvider: ServiceSearchProviderBase, CBCentralManagerDelegate, CBPeripheralDelegate {

    let accessQueue = dispatch_queue_create("BLEDiscoveryProviderQueue", DISPATCH_QUEUE_SERIAL)
    //let services = [CBUUID(string: "43109c05-fd94-4946-9263-7bf3ba4ecac1")]
    let services: [CBUUID] = []
    var timer: NSTimer!
    var manager: CBCentralManager!

    var resolvedServices = NSMutableDictionary(capacity: 0)

    required init(delegate: ServiceSearchProviderDelegate, id: String?) {
        super.init(delegate: delegate, id: id)
        type = ServiceSearchDiscoveryType.CLOUD
        if id != nil {
            return // search by id is not suported for BLE
        }
        self.delegate = delegate
    }

    override func search() {
        isSearching = true
        manager = CBCentralManager(delegate: self, queue: accessQueue, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }

    override func stop() {
        if timer != nil {
            timer.invalidate()
        }
        manager.stopScan()
        manager = nil
        resolvedServices.removeAllObjects()
        isSearching = false
    }

    override func serviceResolutionFaile(serviceId: String, discoveryType: ServiceSearchDiscoveryType) {
        if discoveryType == type {
            // delay de service removal for 3 seconds
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime,self.accessQueue) { [unowned self] in
                self.resolvedServices.removeObjectForKey(serviceId)
            }
        }
    }

    func evaluateDidLostService() {
        dispatch_async(self.accessQueue) { [unowned self] in
            let now = NSDate()
            let keys = NSArray(array: self.resolvedServices.allKeys) as! [String]
            for key in keys {
                if self.resolvedServices[key]!.compare(now) == NSComparisonResult.OrderedAscending {
                    print("BLE -> onServiceLost \(key)")
                    self.resolvedServices.removeObjectForKey(key)
                    self.delegate?.onServiceLost(key, discoveryType: ServiceSearchDiscoveryType.CLOUD)
                }
            }
        }
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn {
            manager.scanForPeripheralsWithServices(services, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true] )
            dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
                self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(5), target: self, selector: Selector("evaluateDidLostService"), userInfo: nil, repeats: true)
            }
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let uuid = getDeviceUUID(advertisementData) {
            if self.resolvedServices[uuid] == nil {
                print("BLE -> didDiscoverPeripheral \(uuid)")
                self.resolvedServices.setObject(NSDate(timeIntervalSinceNow: NSTimeInterval(5)), forKey: uuid)
                let endpoint = "http://\(uuid)-multiscreen.ngrok.com/api/v2/"
                self.delegate?.onServiceFound(uuid, serviceURI: endpoint, discoveryType: ServiceSearchDiscoveryType.CLOUD)
            } else  {
                self.resolvedServices.setObject(NSDate(timeIntervalSinceNow: NSTimeInterval(5)), forKey: uuid)
            }
        }
    }

    func getDeviceUUID(advertisementData: [NSObject : AnyObject]!) -> String? {

        var uuid: String? = nil

        if (advertisementData["kCBAdvDataManufacturerData"] != nil) { //CBAdvertisementDataManufacturerDataKey
            var manufactureID: UInt8 = 0x0000
            let manufacturerData: NSData = advertisementData["kCBAdvDataManufacturerData"] as! NSData
            manufacturerData.getBytes(&manufactureID, range: NSRange(location: 1, length: 1))
            if (manufactureID == 0x75) { // WE got a Samsung Device
                var version: UInt8 = 0x00
                var serviceId: UInt8 = 0x00
                var deviceType: UInt8 = 0x00
                var deviceStatus: UInt8 = 0x00
                var availableService: UInt8 = 0x00

                manufacturerData.getBytes(&version, range: NSRange(location: 2, length: 1))
                manufacturerData.getBytes(&serviceId, range: NSRange(location: 3, length: 1))
                manufacturerData.getBytes(&deviceType, range: NSRange(location: 4, length: 1))

                if version == 0x42 && serviceId == 0x04 && deviceType == 0x01 { // WE got a Samsung TV

                    manufacturerData.getBytes(&deviceStatus, range: NSRange(location: 5, length: 1))
                    manufacturerData.getBytes(&availableService, range: NSRange(location: 6, length: 1))

                    if deviceStatus == 0x14 { // The TV is advertising the MSF UUID
                        let UUIDData = manufacturerData.subdataWithRange(NSRange(location: 7, length: manufacturerData.length - 7))
                        uuid = NSString(data: UUIDData, encoding: NSUTF8StringEncoding) as String?
                    } else if deviceStatus == 0x01 { // The TV is advertising the VD Info for ON Status
                        // VD ADV IND
                        var bdAddr = [UInt8](count:6, repeatedValue: 0x00)
                        var p2pMac = [UInt8](count:6, repeatedValue: 0x00)
                        var p2pListenChannel: UInt8 = 0x00
                        var registeredDevices = [UInt8](count: 6, repeatedValue: 0x00)
                        manufacturerData.getBytes(&bdAddr, range: NSRange(location: 7, length: 6))
                        manufacturerData.getBytes(&p2pMac, range: NSRange(location: 13, length: 6))
                        manufacturerData.getBytes(&p2pListenChannel, range: NSRange(location: 19, length: 1))
                        manufacturerData.getBytes(&registeredDevices, range: NSRange(location: 20, length: 6))
                        print("status: \(deviceStatus.description)")
                        print("availableService: \(availableService.description)")
                        let bdAddrS = NSString(format: "%02X:%02X:%02X:%02X:%02X:%02X",bdAddr[0], bdAddr[1], bdAddr[2], bdAddr[3], bdAddr[4], bdAddr[5] )
                        print("bdAddr: \(bdAddrS.description)")
                        let p2pMacS = NSString(format: "%02X:%02X:%02X:%02X:%02X:%02X",p2pMac[0], p2pMac[1], p2pMac[2], p2pMac[3], p2pMac[4], p2pMac[5] )
                        print("p2pMac: \(p2pMacS.description)")
                        print("p2pListenChannel: \(p2pListenChannel.description)")
                        print("registeredDevices: \(registeredDevices.description)")
                    }
                }
            }
        }
        return uuid
    }
}


//    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
//
//        let gotInfo = { [unowned self] (serviceEndpoints: NSDictionary?) -> Void in
//            if self.isSearching {
//                if serviceEndpoints != nil {
//
//                    self.resolvedServices.setObject(NSDate(timeIntervalSinceNow: NSTimeInterval(10)), forKey: peripheral.identifier.UUIDString)
//                    if let endpoint: String = serviceEndpoints!["se"] as? String {
//                        self.delegate?.onServiceFound( endpoint, discoveryType: ServiceSearchDiscoveryType.LAN)
//                    }
//                    if let endpoint: String = serviceEndpoints!["pse"] as? String {
//                        self.delegate?.onServiceFound(endpoint, discoveryType: ServiceSearchDiscoveryType.CLOUD)
//                    }
//                }
//                self.peripherals.removeObjectForKey(peripheral.identifier.UUIDString)
//            }
//        }
//
//        if self.resolvedServices[peripheral.identifier.UUIDString] == nil {
//            if self.peripherals[peripheral.identifier.UUIDString] == nil {
//                self.peripherals.setObject(peripheral, forKey: peripheral.identifier.UUIDString)
//                let pInfo = PeripheralInfo()
//                pInfo.getInfo(peripheral.identifier, completionHander: gotInfo)
//            }
//        } else  {
//            self.resolvedServices.setObject(NSDate(timeIntervalSinceNow: NSTimeInterval(10)), forKey: peripheral.identifier.UUIDString)
//        }
//    }



class PeripheralInfo: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var timer: NSTimer!
    var completionHander: ((serviceEndpoints: NSDictionary?) -> Void)!
    var peripheralId: NSUUID!
    var outBuf = NSMutableData()
    var gotHeader = false
    var messageLen: Int = 0

    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!


    func getInfo(peripheralId: NSUUID, completionHander: (serviceEndpoints: NSDictionary?) -> Void) {
        self.peripheralId = peripheralId
        self.completionHander = completionHander
        let this = self
        dispatch_async(dispatch_get_main_queue()) { [unowned self]  () -> Void in
            this.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: Selector("timeout"), userInfo: nil, repeats: false)
        }
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn {
            let ps = manager.retrievePeripheralsWithIdentifiers([peripheralId])
            if ps.count == 1 {
                peripheral = ps[0] as CBPeripheral
                manager.connectPeripheral(peripheral, options: nil)
            }
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {

    }

    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil {
            disconnect()
        } else {
            for service in peripheral.services! {
                if service.UUID == CBUUID(string: "43109c05-fd94-4946-9263-7bf3ba4ecac1") {
                    peripheral.discoverCharacteristics([CBUUID(string: "e7add780-b042-4876-aae1-112855353cc1")], forService: service)
                    break;
                }
            }
        }
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if(error != nil) {
            return;
        }
        if service.characteristics!.count > 0 {
            characteristic = service.characteristics![0] as CBCharacteristic
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            let query = ["method":"getService"]
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(query, options: NSJSONWritingOptions.PrettyPrinted)
                sendData(data, peripheral: peripheral)
            } catch _ {
            }
        }
    }

    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            return
        }
        processDataChunck(characteristic.value!, peripheral: peripheral)
    }


    //MARK: internal

    func timeout() {
        if timer != nil {
            timer!.invalidate()
        }
        disconnect()
        completionHander(serviceEndpoints: nil)
    }

    func disconnect() {
        if peripheral.state != .Disconnected {
            manager.cancelPeripheralConnection(peripheral)
        }
    }

    func sendData(data: NSData, peripheral: CBPeripheral) {
        var transferred = 0;
        let buf_size = 20;
        let total_size = data.length + 4;
        var next_buf_size = 0;

        let dataSize: UInt32 = UInt32(data.length)
        let mData = NSMutableData()

        let big = dataSize.bigEndian

        let len = UnsafeMutablePointer<UInt32>.alloc(1)
        len.memory = big

        mData.appendBytes(len, length: sizeof(UInt32))
        mData.appendData(data)

        while ( transferred < total_size ) { // total_size is size of all data to be transferred.
            next_buf_size = total_size - transferred < buf_size ? total_size - transferred : buf_size;
            let dataChunk = mData.subdataWithRange(NSMakeRange(transferred, next_buf_size))
            peripheral.writeValue(dataChunk, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            transferred += next_buf_size;
        }
    }

    func processDataChunck(data: NSData, peripheral: CBPeripheral ){
        if (data.length > 0) {
            outBuf.appendData(data)
            if (!gotHeader && outBuf.length >= 4 ) {
                var msgLen: UInt32 = 0
                outBuf.getBytes(&msgLen, length: sizeof(UInt32))
                msgLen =  msgLen.byteSwapped
                gotHeader = true
                messageLen = Int(msgLen)
            }
            if (gotHeader && outBuf.length == messageLen + 4) {
                timer.invalidate()
                disconnect()
                let response = JSON.parse(data: outBuf.subdataWithRange(NSMakeRange(4, outBuf.length - 4))) as! NSDictionary
                completionHander(serviceEndpoints: response)
            }
        }
    }
    
}
