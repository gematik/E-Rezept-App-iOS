# ``eRpRemoteStorage``

Remote storage implementation for E-Rezept backend API integration.

## Overview

eRpRemoteStorage handles all remote API interactions with the E-Rezept backend services, providing a clean interface for network-based data operations.

This module manages:
- Backend API communication and integration
- Remote data synchronization
- Network request handling and retry logic
- API response parsing and error handling

### Topics

#### Remote API Integration
- E-Rezept backend service communication
- FHIR-based data exchange
- Authentication and authorization handling
- Network error recovery

#### Data Synchronization
- Remote-to-local data sync
- Conflict resolution strategies
- Background sync operations
- Delta synchronization

#### Dependencies
This module depends on:
- ``HTTPClient`` for network communication
- ``FHIRClient`` for FHIR data handling
- ``eRpKit`` for domain models
