import Foundation

public extension String {
   
   func trim() -> String {
      return self.trimmingCharacters(in: CharacterSet.whitespaces)
   }
   
   func indexOf(_ string: String) -> String.Index? {
      return range(of: string, options: .literal, range: nil, locale: nil)?.lowerBound
   }

   public func urlEncode() -> String {
      let encodedURL = self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
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

