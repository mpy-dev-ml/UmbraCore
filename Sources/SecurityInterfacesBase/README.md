# SecurityInterfacesBase

This module contains the core security interface protocols that have minimal dependencies.

## Purpose

The SecurityInterfacesBase module serves as the foundation for the security interface hierarchy in UmbraCore. It defines protocols with minimal dependencies (no Foundation) to avoid circular dependencies in the module graph.

## Key Components

- **XPCServiceProtocolBase**: Core XPC service protocol without Foundation dependencies
- **XPCServiceProtocolDefinitionBase**: Interface for XPC service definition without Foundation dependencies

## Usage

This module should be imported by other modules that need the core security interfaces without bringing in Foundation dependencies.
