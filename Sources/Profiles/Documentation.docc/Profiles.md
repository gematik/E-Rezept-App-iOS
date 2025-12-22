# ``Profiles``

User profile management and multi-profile support.

## Overview

Profiles manages user profile creation, switching, and maintenance within the E-Rezept application, supporting multiple user profiles with individual settings, prescriptions, and authentication states.

This module handle or will handle:

- User profile creation and management
- Profile switching
- Per-profile data isolation
- Profile-specific settings and preferences

### Topics

#### Profile Management

- Profile creation and deletion
- Profile metadata and identification
- Profile switching workflows
- Data isolation between profiles

#### Authentication

- Per-profile authentication states
- Profile-specific identity management
- Authentication token management
- Security context isolation

#### Data Management

- Profile-specific data storage
- Data migration between profiles
- Profile backup and restoration
- Cross-profile data sharing controls

#### Dependencies

This module depends on:

- ``IDP`` for authentication
- ``eRpKit`` for domain models
- ``eRpLocalStorage`` for data persistence
- ``VAUClient`` and ``TrustStore`` for security
- ``Pharmacy`` and ``eRpRemoteStorage`` for external services
