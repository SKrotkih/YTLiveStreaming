
import Foundation
import SwiftyJSON

public protocol Decodable  {
  static func decode(_ json: JSON) -> Self
}
