import Foundation

public extension String {
   func websiteLink() -> String {
      var str = self
      if str.hasPrefix("http://") {
         str = str[str.characters.index(str.startIndex, offsetBy: "http://".characters.count)..<str.endIndex]
      }
      
      if str.hasPrefix("www.") {
         str = str[str.characters.index(str.startIndex, offsetBy: "www.".characters.count)..<str.endIndex]
      }
      
      if let index = str.characters.index(of: "/") {
         str = str.substring(to: index)
      }
      
      return str
   }
   
   func trim() -> String {
      return self.trimmingCharacters(in: CharacterSet.whitespaces)
   }
   
   func indexOf(_ string: String) -> String.Index? {
      return range(of: string, options: .literal, range: nil, locale: nil)?.lowerBound
   }

   public func urlEncode() -> String {
      
      let encodedURL = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
      
//      let encodedURL2 = CFURLCreateStringByAddingPercentEscapes(nil,
//                                                               self as NSString,
//                                                               nil,
//                                                               "!@#$%&*'();:=+,/?[]" as CFString!,
//                                                               CFStringBuiltInEncodings.UTF8.rawValue)
      return encodedURL!
   }
   
}

public func merge(one: [String: String]?, _ two: [String:String]?) -> [String: String]? {
   var dict: [String: String]?
   if let one = one {
      dict = one
      if let two = two {
         for (key, value) in two {
            dict![key] = value
         }
      }
   } else {
      dict = two
   }
   return dict
}

