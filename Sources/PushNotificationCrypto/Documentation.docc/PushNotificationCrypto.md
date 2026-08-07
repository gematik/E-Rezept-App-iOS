# ``PushNotificationCrypto``

End-to-end encryption for push notifications as specified by gemF_PushNotification.

## Overview

PushNotificationCrypto implements the FdV-side cryptography of the gematik push notification
encryption concept (gemF_PushNotification). It derives and manages the monthly key material used
to encrypt and decrypt push notification payloads, so that notification content remains
confidential between the Fachdienst and the device.

This module handles:

- Generation of the initial shared secret (iss) during FdV instance registration
- HKDF-SHA256 based derivation of monthly shared-secret/AES-GCM key pairs
- Stepwise key chain advancement when notifications arrive for a future month
- Retention and cleanup of outdated key generations
- AES/GCM decryption and PNM1 payload framing/unframing
- Keychain-backed persistence of key material shared with the notification service extension

### Topics

#### Key Derivation

- ``PushNotificationKeyDerivation``
- ``PushNotificationKeyGenerationManager``
- ``KeyGeneration``

#### Crypto Client

- ``PushNotificationCrypto``
- ``PushNotificationCryptoError``
- ``PNM1Framing``

#### Storage

- ``PushNotificationCryptoStorage``

#### Dependencies

This module depends on:

- ``CodedError`` for structured error codes
- `CryptoKit` for HKDF and AES/GCM
- `Security` for Keychain-backed storage shared with the notification service extension
