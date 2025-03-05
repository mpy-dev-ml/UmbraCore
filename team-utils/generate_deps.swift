import Foundation

let packageSwift=try String(contentsOfFile: "Package.swift", encoding: .utf8)

// Extract dependencies section
let depsPattern=#"dependencies:\s*\[\s*([^\]]+)\s*\]"#
let depsRegex=try NSRegularExpression(pattern: depsPattern, options: [.dotMatchesLineSeparators])
let depsRange=NSRange(packageSwift.startIndex..<packageSwift.endIndex, in: packageSwift)
guard let match=depsRegex.firstMatch(in: packageSwift, options: [], range: depsRange) else {
  fatalError("Could not find dependencies section")
}

let deps=String(packageSwift[Range(match.range(at: 1), in: packageSwift)!])
  .split(separator: "\n")
  .map { $0.trimmingCharacters(in: .whitespaces) }
  .filter { !$0.isEmpty }

// Parse dependencies
var modules: [[String: Any]]=[]
for dep in deps {
  let urlPattern=#"url:\s*"([^"]+)""#
  let versionPattern=#"from:\s*"([^"]+)""#

  let urlRegex=try NSRegularExpression(pattern: urlPattern, options: [])
  let versionRegex=try NSRegularExpression(pattern: versionPattern, options: [])

  let urlRange=NSRange(dep.startIndex..<dep.endIndex, in: dep)
  let versionRange=NSRange(dep.startIndex..<dep.endIndex, in: dep)

  guard
    let urlMatch=urlRegex.firstMatch(in: dep, options: [], range: urlRange),
    let versionMatch=versionRegex.firstMatch(in: dep, options: [], range: versionRange)
  else {
    continue
  }

  let url=String(dep[Range(urlMatch.range(at: 1), in: dep)!])
  let version=String(dep[Range(versionMatch.range(at: 1), in: dep)!])

  let name=url.split(separator: "/").last!
    .replacingOccurrences(of: ".git", with: "")
    .replacingOccurrences(of: "-", with: "")
  let c99name=name.lowercased()

  let module: [String: Any]=[
    "name": name,
    "module_name": name,
    "c99name": c99name,
    "package_identity": c99name,
    "label": "@\(c99name)//:Sources",
    "product_memberships": [name],
    "remote": [
      "commit": "",
      "remote": url,
      "version": version
    ],
    "src_type": "swift",
    "srcs": ["Sources/**/*.swift"],
    "deps": []
  ]
  modules.append(module)
}

// Create products from modules
let products=modules.map { module in
  [
    "name": module["name"]!,
    "package_identity": module["package_identity"]!,
    "identity": module["name"]!,
    "label": "@\(module["package_identity"]!)//:Sources",
    "type": "library",
    "targets": [module["name"]!]
  ]
}

// Create final JSON
let json: [String: Any]=[
  "modules": modules,
  "products": products
]

// Convert to JSON string
let jsonData=try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
let jsonString=String(data: jsonData, encoding: .utf8)!

// Write to deps.json
try jsonString.write(toFile: ".deps.json", atomically: true, encoding: .utf8)

print("Generated repository names:")
for module in modules {
  print("- \(module["package_identity"]!)")
}
