# ``TrustStore``

Module handling trust with a given TrustAnchor and OCSPResponses.

## Overview

TrustStore manages certificate validation, trust anchor verification, and OCSP (Online Certificate Status Protocol) response handling for secure communication within the E-Rezept ecosystem.

This module provides:

- Certificate chain validation
- Trust anchor management
- OCSP response verification
- Certificate revocation checking
- PKI (Public Key Infrastructure) operations

### Topics

### Trust Management

- Trust anchor configuration and validation
- Certificate chain verification
- Root certificate management
- Trust policy enforcement

#### Certificate Validation

- X.509 certificate parsing and validation
- Certificate expiration checking
- Certificate revocation list (CRL) handling
- OCSP response processing

#### Security Operations

- PKI operations and utilities
- Cryptographic signature verification
- Certificate path building
- Trust decision making

#### Dependencies

This module depends on:

- ``HTTPClient`` for OCSP requests
