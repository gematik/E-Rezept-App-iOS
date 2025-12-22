# ``Pharmacy``

Contains a client for the APOVZD that uses the FHIR protocol to retrieve pharmacies.

## Overview

The Pharmacy module provides comprehensive pharmacy search and information retrieval capabilities through the APOVZD (Apothekenverzeichnisdienst) using FHIR-compliant communication protocols.

This module handles:

- Pharmacy search and discovery
- APOVZD integration via FHIR protocol
- Pharmacy location and contact information
- Service availability and capabilities
- Opening hours and accessibility features

### Topics

#### Pharmacy Services

- Pharmacy search by location, name, or services
- Detailed pharmacy information retrieval
- Service availability verification
- Contact and location data management

#### APOVZD Integration

- FHIR-based pharmacy directory access
- Real-time pharmacy information updates
- Search filtering and sorting capabilities
- Geographic proximity calculations

#### Dependencies

This module depends on:

- ``HTTPClient`` for network communication
- ``FHIRClient`` for FHIR data handling
- ``eRpKit`` for domain models
