# ``IDP``

Module containing communication with identity provider.

## Overview

The IDP (Identity Provider) module handles authentication and re-authentication mechanisms including SSO (Single Sign-On) and biometric authentication via registered private/public key pairs.

This module provides:

- Primary authentication with identity providers
- Biometric authentication support
- Private/public key pair management
- Token management and refresh (via SSO-Token)
- Secure session handling

### Topics

#### Authentication Methods

- Primary authentication flows
- Biometric authentication (Touch ID, Face ID)
- Smart card authentication support

#### Security Features

- Private/public key pair generation and management
- Token lifecycle management
- Secure credential storage
- Authentication state management

#### Key Management

- Cryptographic key generation
- Key pair registration and validation
- Secure key storage and retrieval
- Key rotation and expiration handling

#### Dependencies

This module depends on:

- ``eRpResources`` for resources
- ``AsyncHelpers`` for async operations
