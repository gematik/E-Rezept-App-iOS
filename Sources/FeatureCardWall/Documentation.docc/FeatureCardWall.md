# ``FeatureCardWall``

Card wall authentication feature for health card integration.

## Overview

FeatureCardWall provides the card wall authentication interface, enabling users to authenticate using health cards (eGK - elektronische Gesundheitskarte) through NFC communication and smart card protocols.

This module handles:
- Health card authentication workflows
- NFC card reading and communication
- Smart card protocol implementation
- Card wall user interface components
- PIN verification and management

### Topics

#### Authentication Features
- Health card (eGK) authentication
- NFC-based card communication
- PIN entry and verification
- Card authentication workflows

#### User Interface
- Card wall authentication screens
- NFC reader interaction guidance
- Error handling and user feedback
- Accessibility features for card authentication

#### Smart Card Integration
- Health card protocol implementation
- Secure card communication
- Card reader management
- Authentication state handling

#### Dependencies
This module depends on:
- ``eRpStyleKit`` for UI components
- ``eRpKit`` for domain models
- ``Profiles`` and ``Settings`` for user management
- ``IDPLive`` for identity provider integration
- ``FeatureHelpers`` for shared utilities
