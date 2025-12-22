# ``VAUClient``

Wraps VAU Protocol communication in a convenient HTTPInterceptor.

## Overview

VAUClient provides VAU (Vertrauenswürdige Ausführungsumgebung / Trusted Execution Environment) protocol implementation as an HTTP interceptor, enabling secure end-to-end communication with E-Rezept backend services.

This module handles:

- VAU protocol implementation
- Secure channel establishment
- Request/response encryption and decryption
- HTTP interceptor integration for transparent operation

### Topics

#### VAU Protocol

- Secure channel establishment
- End-to-end encryption implementation
- VAU handshake procedures
- Protocol compliance verification

#### HTTP Integration

- Transparent HTTP request/response interception
- Automatic encryption/decryption handling
- Seamless integration with existing HTTP flows
- Error handling and recovery

#### Security Features

- Cryptographic operations for VAU
- Secure key exchange
- Message integrity verification
- Anti-replay protection

#### Dependencies

This module depends on:

- ``HTTPClient`` for network communication
- ``TrustStore`` for certificate validation
- ``AsyncHelpers`` for async operations
