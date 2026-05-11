Flutter Architecture
Overview
Provides architectural guidance and best practices for building scalable Flutter applications using MVVM pattern, layered architecture, and recommended design patterns from the Flutter team.

Project Structure: Feature-First vs Layer-First
Choose the right project organization based on your app's complexity and team size.

Feature-First (Recommended for teams)
Organize code by business features:

*.txt
Plaintext
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── todos/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── core/
│   ├── data/
│   └── ui/
└── main.dart
When to use:

Medium to large apps (10+ features)
Team development (2+ developers)
Frequently adding/removing features
Complex business logic
Benefits:

Features are self-contained units
Easy to add/remove entire features
Clear feature boundaries
Reduced merge conflicts
Teams work independently on features
See Feature-First Guide for complete implementation details.

Layer-First (Traditional)
Organize code by architectural layers:

*.txt
Plaintext
lib/
├── data/
│   ├── repositories/
│   ├── services/
│   └── models/
├── domain/
│   ├── use-cases/
│   └── entities/
├── presentation/
│   ├── views/
│   └── viewmodels/
└── shared/
When to use:

Small to medium apps
Few features (<10)
Solo developers or small teams
Simple business logic
Benefits:

Clear separation by layer
Easy to find components by type
Less nesting
Quick Start
Start with these core concepts:

Separation of concerns - Split app into UI and Data layers
MVVM pattern - Use Views, ViewModels, Repositories, and Services
Single source of truth - Repositories hold the authoritative data
Unidirectional data flow - State flows from data → logic → UI
For detailed concepts, see Concepts.

Architecture Layers
Flutter apps should be structured in layers:

UI Layer: Views (widgets) and ViewModels (UI logic)
Data Layer: Repositories (SSOT) and Services (data sources)
Domain Layer (optional): Use-cases for complex business logic
See Layers Guide for detailed layer responsibilities and interactions.

Core Components
Views
Compose widgets for UI presentation
Contain minimal logic (animations, simple conditionals, routing)
Receive data from ViewModels
Pass events via ViewModel commands
ViewModels
Transform repository data into UI state
Manage UI state and commands
Handle business logic for UI interactions
Expose state as streams or change notifiers
Repositories
Single source of truth for data types
Aggregate data from services
Handle caching, error handling, retry logic
Expose data as domain models
Services
Wrap external data sources (APIs, databases, platform APIs)
Stateless data access layer
One service per data source
Design Patterns
Common patterns for robust Flutter apps:

Command Pattern - Encapsulate actions with Result handling
Result Type - Type-safe error handling
Repository Pattern - Abstraction over data sources
Offline-First - Optimistic UI updates with sync
See Design Patterns for implementation details.

When to Use This Skill
Use this skill when:

Designing or refactoring Flutter app architecture
Choosing between feature-first and layer-first project structure
Implementing MVVM pattern in Flutter
Creating scalable app structure for teams
Adding new features to existing architecture
Applying best practices and design patterns
Resources
references/
concepts.md - Core architectural principles (separation of concerns, SSOT, UDF)
feature-first.md - Feature-first project organization and best practices
mvvm.md - MVVM pattern implementation in Flutter
layers.md - Detailed layer responsibilities and interactions
design-patterns.md - Common patterns and implementations
assets/
command.dart - Command pattern template for encapsulating actions
result.dart - Result type for safe error handling
examples/ - Code examples showing architecture in practice