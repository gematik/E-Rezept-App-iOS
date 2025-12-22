# ``eRpFeatures``

The main eRp application features module containing all user-facing functionality.

## Overview

eRpFeatures is the primary module that orchestrates all the application features for the German E-Rezept app. It brings together UI components, business logic, and data management to provide a complete prescription management solution.

This module includes:

- User interface components and views
- Main application workflows
- Integration with pharmacy services
- Prescription management features
- Card wall authentication
- Settings and profile management

### Topics

#### Core Features

- Prescription management and redemption
- Pharmacy search and selection
- User authentication and security
- Profile and settings management

#### Architecture

- [ErrorHandling](errorhandling)
- [requirement-notes](requirement-notes)

#### Dependencies

This module integrates with all other major modules including:

- ``eRpKit`` for business logic
- ``eRpStyleKit`` for UI components
- ``eRpLocalStorage`` and ``eRpRemoteStorage`` for data management
- ``Pharmacy`` for pharmacy-related functionality
- ``IDP`` for identity provider integration
