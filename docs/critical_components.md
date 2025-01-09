# Critical Components - DO NOT MODIFY Without Explicit Request

## API Integration
1. Cryptocurrency Data Source
   - Using Coinpaprika API (NOT CoinCap)
   - Endpoint: https://api.coinpaprika.com/v1/tickers
   - Required for full cryptocurrency coverage
   - DO NOT change API without explicit request

## UI Components
1. Cryptocurrency List View
   - Column layout with all fields (Name, Price, 24h %, Market Cap, Volume)
   - Long-press functionality for quick portfolio addition
   - Card-based layout with proper spacing and alignment

2. Portfolio Management
   - Multiple methods for adding cryptocurrencies:
     - Long-press quick-add
     - Detail screen add button
   - Portfolio selection dropdown
   - Amount input functionality

3. Data Display
   - Price formatting with $ and decimal places
   - Market cap in billions (B)
   - Volume in millions (M)
   - Color coding for positive/negative changes

## Core Functionality
1. Portfolio Operations
   - Adding cryptocurrencies via multiple methods
   - Portfolio selection
   - Amount input and validation
   - Data persistence

2. Data Management
   - SharedPreferences storage
   - Portfolio state management
   - Cryptocurrency data updates

## Implementation Rules
1. When Making Changes:
   - NEVER remove or modify existing UI layouts without explicit request
   - NEVER change working interaction methods (long-press, tap actions)
   - NEVER modify data formatting without discussion
   - NEVER remove or alter existing features while adding new ones

2. Before Implementing Changes:
   - Review this document
   - Identify which components might be affected
   - If a critical component needs modification, seek clarification
   - Plan changes to avoid disrupting existing functionality

3. After Making Changes:
   - Verify all critical components still work
   - Check all interaction methods are preserved
   - Ensure data formatting remains consistent
   - Test all portfolio operations

## Change Request Protocol
1. For each change request:
   - Clearly identify the scope of changes
   - List any critical components that might be affected
   - If request is unclear about preserving existing features, ask for clarification
   - Implement changes in isolation from working components

2. Testing Requirements:
   - Test all preserved functionality after changes
   - Verify no unintended side effects
   - Check all critical components remain intact

## Version Control Guidelines
1. Commit Messages:
   - Clearly state intended changes
   - List any modifications to critical components
   - Document any necessary changes to existing functionality

2. Code Review:
   - Review changes against this critical components list
   - Verify no unintended modifications
   - Ensure all working features are preserved
