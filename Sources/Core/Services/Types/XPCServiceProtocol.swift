import Foundation
import XPCProtocolsCore

// Re-export XPCServiceProtocolStandard from XPCProtocolsCore
// This replaces the deprecated SecurityInterfaces.XPCServiceProtocol
public typealias XPCServiceProtocol = XPCProtocolsCore.XPCServiceProtocolStandard
