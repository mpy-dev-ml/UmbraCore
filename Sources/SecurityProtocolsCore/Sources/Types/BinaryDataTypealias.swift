// BinaryDataTypealias.swift
// SecurityProtocolsCore
//
// Created as part of the UmbraCore Foundation Decoupling project
//

import UmbraCoreTypes
/// Legacy compatibility typealias
/// This allows code that previously used BinaryData to work with SecureBytes
/// without requiring extensive changes.
public typealias BinaryData = SecureBytes
