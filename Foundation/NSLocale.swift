// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


import CoreFoundation

open class Locale: NSObject, NSCopying, NSSecureCoding {
    typealias CFType = CFLocale
    private var _base = _CFInfo(typeID: CFLocaleGetTypeID())
    private var _identifier: UnsafeMutableRawPointer? = nil
    private var _cache: UnsafeMutableRawPointer? = nil
    private var _prefs: UnsafeMutableRawPointer? = nil
#if os(OSX) || os(iOS)
    private var _lock = pthread_mutex_t()
#elseif os(Linux)
    private var _lock = Int32(0)
#endif
    private var _nullLocale = false
    
    internal var _cfObject: CFType {
        return unsafeBitCast(self, to: CFType.self)
    }
    
    open func objectForKey(_ key: String) -> AnyObject? {
        return CFLocaleGetValue(_cfObject, key._cfObject)
    }
    
    open func displayNameForKey(_ key: String, value: String) -> String? {
        return CFLocaleCopyDisplayNameForPropertyValue(_cfObject, key._cfObject, value._cfObject)?._swiftObject
    }
    
    public init(localeIdentifier string: String) {
        super.init()
        _CFLocaleInit(_cfObject, string._cfObject)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        if aDecoder.allowsKeyedCoding {
            guard let identifier = aDecoder.decodeObjectOfClass(NSString.self, forKey: "NS.identifier") else {
                return nil
            }
            self.init(localeIdentifier: identifier.bridge())
        } else {
            NSUnimplemented()
        }
    }
    
    open override func copy() -> AnyObject {
        return copy(with: nil)
    }
    
    open func copy(with zone: NSZone? = nil) -> AnyObject { 
        return self 
    }
    
    open func encode(with aCoder: NSCoder) {
        if aCoder.allowsKeyedCoding {
            let identifier = CFLocaleGetIdentifier(self._cfObject)
            aCoder.encode(identifier, forKey: "NS.identifier")
        } else {
            NSUnimplemented()
        }
    }
    
    public static func supportsSecureCoding() -> Bool {
        return true
    }
}

extension Locale {
    open class var current: Locale {
        return CFLocaleCopyCurrent()._nsObject
    }
    
    open class func systemLocale() -> Locale {
        return CFLocaleGetSystem()._nsObject
    }
}

extension Locale {
    
    open class func availableLocaleIdentifiers() -> [String] {
        var identifiers = Array<String>()
        for obj in CFLocaleCopyAvailableLocaleIdentifiers()._nsObject {
            identifiers.append((obj as! NSString)._swiftObject)
        }
        return identifiers
    }
    
    open class func ISOLanguageCodes() -> [String] {
        var identifiers = Array<String>()
        for obj in CFLocaleCopyISOLanguageCodes()._nsObject {
            identifiers.append((obj as! NSString)._swiftObject)
        }
        return identifiers
    }
    
    open class func ISOCountryCodes() -> [String] {
        var identifiers = Array<String>()
        for obj in CFLocaleCopyISOCountryCodes()._nsObject {
            identifiers.append((obj as! NSString)._swiftObject)
        }
        return identifiers
    }
    
    open class func ISOCurrencyCodes() -> [String] {
        var identifiers = Array<String>()
        for obj in CFLocaleCopyISOCurrencyCodes()._nsObject {
            identifiers.append((obj as! NSString)._swiftObject)
        }
        return identifiers
    }
    
    open class func commonISOCurrencyCodes() -> [String] {
        var identifiers = Array<String>()
        for obj in CFLocaleCopyCommonISOCurrencyCodes()._nsObject {
            identifiers.append((obj as! NSString)._swiftObject)
        }
        return identifiers
    }
    
    open class func preferredLanguages() -> [String] {
        var identifiers = Array<String>()
        for obj in CFLocaleCopyPreferredLanguages()._nsObject {
            identifiers.append((obj as! NSString)._swiftObject)
        }
        return identifiers
    }
    
    open class func componentsFromLocaleIdentifier(_ string: String) -> [String : String] {
        var comps = Dictionary<String, String>()
        let values = CFLocaleCreateComponentsFromLocaleIdentifier(kCFAllocatorSystemDefault, string._cfObject)._nsObject
        values.enumerateKeysAndObjects([]) { (k, v, stop) in
            let key = (k as! NSString)._swiftObject
            let value = (v as! NSString)._swiftObject
            comps[key] = value
        }
        return comps
    }
    
    open class func localeIdentifierFromComponents(_ dict: [String : String]) -> String {
        return CFLocaleCreateLocaleIdentifierFromComponents(kCFAllocatorSystemDefault, dict._cfObject)._swiftObject
    }
    
    open class func canonicalLocaleIdentifierFromString(_ string: String) -> String {
        return CFLocaleCreateCanonicalLocaleIdentifierFromString(kCFAllocatorSystemDefault, string._cfObject)._swiftObject
    }
    
    open class func canonicalLanguageIdentifierFromString(_ string: String) -> String {
        return CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorSystemDefault, string._cfObject)._swiftObject
    }
    
    open class func localeIdentifierFromWindowsLocaleCode(_ lcid: UInt32) -> String? {
        return CFLocaleCreateLocaleIdentifierFromWindowsLocaleCode(kCFAllocatorSystemDefault, lcid)._swiftObject
    }
    
    open class func windowsLocaleCodeFromLocaleIdentifier(_ localeIdentifier: String) -> UInt32 {
        return CFLocaleGetWindowsLocaleCodeFromLocaleIdentifier(localeIdentifier._cfObject)
    }
    
    open class func characterDirectionForLanguage(_ isoLangCode: String) -> NSLocaleLanguageDirection {
        let dir = CFLocaleGetLanguageCharacterDirection(isoLangCode._cfObject)
#if os(OSX) || os(iOS)
        return NSLocaleLanguageDirection(rawValue: UInt(dir.rawValue))!
#else
        return NSLocaleLanguageDirection(rawValue: UInt(dir))!
#endif
    }
    
    open class func lineDirectionForLanguage(_ isoLangCode: String) -> NSLocaleLanguageDirection {
        let dir = CFLocaleGetLanguageLineDirection(isoLangCode._cfObject)
#if os(OSX) || os(iOS)
        return NSLocaleLanguageDirection(rawValue: UInt(dir.rawValue))!
#else
        return NSLocaleLanguageDirection(rawValue: UInt(dir))!
#endif
    }
}

public enum NSLocaleLanguageDirection : UInt {
    case unknown
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
}

public let NSCurrentLocaleDidChangeNotification: String = "kCFLocaleCurrentLocaleDidChangeNotification"

public let NSLocaleIdentifier: String = "kCFLocaleIdentifierKey"
public let NSLocaleLanguageCode: String = "kCFLocaleLanguageCodeKey"
public let NSLocaleCountryCode: String = "kCFLocaleCountryCodeKey"
public let NSLocaleScriptCode: String = "kCFLocaleScriptCodeKey"
public let NSLocaleVariantCode: String = "kCFLocaleVariantCodeKey"
public let NSLocaleExemplarCharacterSet: String = "kCFLocaleExemplarCharacterSetKey"
public let NSLocaleCalendar: String = "kCFLocaleCalendarKey"
public let NSLocaleCollationIdentifier: String = "collation"
public let NSLocaleUsesMetricSystem: String = "kCFLocaleUsesMetricSystemKey"
public let NSLocaleMeasurementSystem: String = "kCFLocaleMeasurementSystemKey"
public let NSLocaleDecimalSeparator: String = "kCFLocaleDecimalSeparatorKey"
public let NSLocaleGroupingSeparator: String = "kCFLocaleGroupingSeparatorKey"
public let NSLocaleCurrencySymbol: String = "kCFLocaleCurrencySymbolKey"
public let NSLocaleCurrencyCode: String = "currency"
public let NSLocaleCollatorIdentifier: String = "kCFLocaleCollatorIdentifierKey"
public let NSLocaleQuotationBeginDelimiterKey: String = "kCFLocaleQuotationBeginDelimiterKey"
public let NSLocaleQuotationEndDelimiterKey: String = "kCFLocaleQuotationEndDelimiterKey"
public let NSLocaleCalendarIdentifier: String = "kCFLocaleCalendarIdentifierKey"
public let NSLocaleAlternateQuotationBeginDelimiterKey: String = "kCFLocaleAlternateQuotationBeginDelimiterKey"
public let NSLocaleAlternateQuotationEndDelimiterKey: String = "kCFLocaleAlternateQuotationEndDelimiterKey"

extension CFLocale : _NSBridgable {
    typealias NSType = Locale
    internal var _nsObject: Locale {
        return unsafeBitCast(self, to: NSType.self)
    }
}
