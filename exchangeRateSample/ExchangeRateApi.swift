//
//  ExchangeRateApi.swift
//  exchangeRateSample
//
//  Created by はるふ on 2016/09/12.
//  Copyright © 2016年 ha1f. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

// ATSを無効化する必要有

struct ExchangeRate {
    var open = 0.0
    var bid = 0.0
    var ask = 0.0
    var low = 0.0
    var high = 0.0
    
    var fromCurrencyCode: String = ""
    var toCurrencyCode: String = ""
}

class ExchangeRateModel {
    private var data = [String: [String: ExchangeRate]]()
    
    func fetch(completionHandler: ()->() = {}) {
        ExchangeRateApi.fetch { [weak self] data in
            var dict = [String: [String: ExchangeRate]]()
            data.forEach { rate in
                var d = dict[rate.fromCurrencyCode] ?? [:]
                d[rate.toCurrencyCode] = rate
                dict[rate.fromCurrencyCode] = d
            }
            self?.data = dict
            completionHandler()
        }
    }
    
    // USD, JPYが102, bid < ask
    func translate(from from: ExchangeRateApi.CountryCode, to: ExchangeRateApi.CountryCode, value: Double) -> Double? {
        if let rate = data[from.rawValue]?[to.rawValue]?.bid {
            return value * rate
        }
        if let inverseRate = data[to.rawValue]?[from.rawValue]?.ask where inverseRate != 0 {
            let rate = 1.0 / inverseRate
            return value * rate
        }
        return nil
    }
    
}

class ExchangeRateApi {
    static let URL = "http://www.gaitameonline.com/rateaj/getrate"
    
    enum CountryCode: String {
        case JPY = "JPY"
        case USD = "USD"
        case EUR = "EUR"
        case GBP = "GBP"
        case NZD = "NZD"
        case CHF = "CHF"
        case CAD = "CAD"
        case AUD = "AUD"
    }
    
    private static func client(method: Alamofire.Method) -> Request {
        return Alamofire.request(method, URL)
    }
    
    static func fetch(handler: [ExchangeRate] -> ()) {
        client(.GET).responseJSON { response in
            guard let data = response.result.value.map({ JSON($0)["quotes"] })?.array else {
                handler([])
                return
            }
            handler(data.map{ json in constructExchangeRate(json) })
        }
    }
    
    private static func constructExchangeRate(json: JSON) -> ExchangeRate {
        var res = ExchangeRate()
        res.ask = json["ask"].string.map{ NSString(string: $0).doubleValue } ?? 0
        res.bid = json["bid"].string.map{ NSString(string: $0).doubleValue } ?? 0
        res.low = json["low"].string.map{ NSString(string: $0).doubleValue } ?? 0
        res.open = json["open"].string.map{ NSString(string: $0).doubleValue } ?? 0
        res.high = json["high"].string.map{ NSString(string: $0).doubleValue } ?? 0
        if let pair = json["currencyPairCode"].string {
            let characters = pair.characters
            let separateIndex = characters.startIndex.advancedBy(3)
            res.fromCurrencyCode = String(characters[characters.startIndex..<separateIndex])
            res.toCurrencyCode = String(characters[separateIndex..<characters.endIndex])
        }
        return res
    }
}
