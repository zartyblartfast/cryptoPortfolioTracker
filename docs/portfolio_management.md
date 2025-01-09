# Portfolio Management Implementation Guide

## Core Components

### 1. Portfolio Structure
- Portfolios are managed through the `_CryptoListScreenState` class
- Each portfolio is an instance of the `Portfolio` class containing:
  - Name
  - List of cryptocurrencies with amounts

### 2. Key Functions

#### addToPortfolio
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

#### Portfolio State Management
- `selectedPortfolioIndex` tracks the current portfolio
- Portfolio changes are always followed by `savePortfolios()`
- State updates use `setState` for UI refresh

### 3. Important UI Elements

#### Dropdown Implementation
- Uses standard Flutter `DropdownButton`
- Maintains value synchronization with `selectedPortfolioIndex`
- Works within dialog context using `StatefulBuilder`

#### Dialog Structure
```dart
AlertDialog(
  title: Text(...),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      DropdownButton<int>(...),
      TextField(...)
    ]
  )
)
```

## Guidelines for Modifications

### DO NOT:
1. Change the basic dialog structure
2. Modify the state management pattern
3. Replace standard DropdownButton without thorough testing
4. Add constraints that might affect dialog layout
5. Modify the portfolio saving mechanism

### Safe to Modify:
1. Visual styling (colors, padding, etc.)
2. Input validation logic
3. Success/error messages
4. Additional non-critical UI elements

## Testing New Changes
1. Always test portfolio selection
2. Verify amount input works
3. Confirm save operation completes
4. Check portfolio updates in UI
5. Verify persistence across app restarts

Remember: The current implementation is stable and working. Any changes should be incremental and thoroughly tested before merging.
