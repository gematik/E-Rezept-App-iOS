# ``eRpKit``

Handles E-Rezept domain specific business logic and helper methods.

## Overview

eRpKit orchestrates remote API and local storage into a single storage interface, providing the core business logic for prescription management in the German E-Rezept system.

This module serves as the central hub for:

- Domain-specific business rules and validation
- Data model definitions for prescriptions and related entities
- Coordination between remote and local storage layers
- Core utilities and helper functions

The module acts as the primary coordination layer, combining data from both remote APIs and local storage to provide a unified interface for the application's business logic.

### Topics

#### Core Business Logic

- Prescription validation and processing
- Data model definitions
- Business rule enforcement
- Storage coordination

#### Key Components

- Domain models for prescriptions, pharmacies, and users
- Business logic for prescription workflows
- Integration interfaces for storage layers
- Utility functions and extensions

- Core data models and entities

#### Dependencies

This module depends on:

- ``IDP`` for identity and authentication
- ``FHIRClient`` for FHIR data handling
