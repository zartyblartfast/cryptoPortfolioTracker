# Portfolio Management Implementation Guide

## Core Components

### 1. Portfolio Structure
- Portfolios are managed through the `_CryptoListScreenState` class
- Each portfolio is an instance of the `Portfolio` class containing:
  - Name
  - List of cryptocurrencies with amounts

### 2. User Interaction Methods

#### Adding Cryptocurrencies
**Multiple methods must be preserved:**
1. Long-press on cryptocurrency in list view
   - Quick add functionality
   - Opens add to portfolio dialog
   - Must remain as primary quick-add method

2. Detail screen add button
   - Secondary method through CryptoDetailScreen
   - Provides same portfolio selection dialog
   - Maintains consistency with quick-add method

#### Portfolio Dialog Implementation
```dart
void addToPortfolio(Cryptocurrency crypto)
```
**Critical Implementation Notes:**
- Uses `StatefulBuilder` for dialog state management
- Maintains working dropdown with `targetPortfolioIndex`
- DO NOT modify the basic dialog structure as it's crucial for proper input handling
- Uses `setState` for portfolio updates
- Saves changes using `savePortfolios()`

**Key Components to Preserve:**
- Dialog layout with Column and mainAxisSize.min
- Basic DropdownButton implementation
- TextField for amount input
- Proper state management using setDialogState

### 3. State Management

#### Portfolio State
- `selectedPortfolioIndex` tracks the current portfolio
- Portfolio changes are always followed by `savePortfolios()`
- State updates use `setState` for UI refresh
- Default portfolio is created if none exists

#### Data Persistence
- Uses SharedPreferences for storage
- Automatic saving on all portfolio changes
- Loads portfolios on app initialization

### 4. API Integration

#### ApiService
- Handles all CoinCap API communications
- Updates cryptocurrency prices periodically
- Maintains separation of concerns
- Supports dependency injection for testing

### 5. Testing Considerations

#### Required Test Coverage
- Portfolio model unit tests
- Widget tests for portfolio interactions
- Mock API responses for testing
- Dialog interaction tests

### 6. Implementation Guidelines

#### DO NOT Remove or Modify:
1. Long-press functionality for quick adds
2. Any existing portfolio management features
3. Working dialog implementations
4. Multiple methods for adding cryptocurrencies

#### When Making Changes:
1. Preserve all existing user interaction methods
2. Maintain current dialog structures
3. Keep both quick-add and detail view add methods
4. Test all portfolio operations after changes

### 7. Error Handling
- Validate all user inputs
- Handle API failures gracefully
- Prevent portfolio data loss
- Maintain at least one portfolio at all times
