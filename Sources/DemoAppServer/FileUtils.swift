/**
* Copyright IBM Corporation 2017
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Foundation
import LoggerAPI

public class FileUtils {

  public static func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
    let initialPath = #file
    let fileManager = FileManager.default

    Log.debug("initialPath: \(initialPath)")
    Log.debug("useFallback: \(useFallback)")

    // We need to search for the root directory of the package
    // by searching for Package.swift.
    let components = initialPath.characters.split(separator: "/").map(String.init)
    var rootPath = initialPath
    var filePath = ""
    for index in stride(from: components.count-1, through: 0, by: -1) {
      let subArray = components[0...index]
      rootPath = "/" + subArray.joined(separator: "/")
      if fileManager.fileExists(atPath: rootPath + "/Package.swift") {
        filePath = rootPath + "/" + relativePath
        break
      }
    }

    if filePath == "" {
      return nil
    }

    if fileManager.fileExists(atPath: filePath) {
      return filePath
    } else if useFallback {
      let currentPath = fileManager.currentDirectoryPath
      filePath = currentPath + relativePath
      if fileManager.fileExists(atPath: filePath) {
        return filePath
      } else {
        return nil
      }
    } else {
      return nil
    }
  }

  public static func getURL(filePath: String) -> URL {
    let url = URL(fileURLWithPath: filePath).standardized
    return url
  }
}
