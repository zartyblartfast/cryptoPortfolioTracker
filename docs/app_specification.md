# Crypto Portfolio Tracker Specification

## Overview
A Flutter web application for tracking cryptocurrency portfolios, allowing users to monitor their cryptocurrency investments and track their portfolio value over time.

## Core Features

### 1. Cryptocurrency List View
- Display list of cryptocurrencies with current market data
- Show price, 24h change percentage, and other relevant information
- **Quick Add Feature**: Long-press on any cryptocurrency to quickly add it to a portfolio
- Search functionality to filter cryptocurrencies
- Tap on cryptocurrency to view detailed information

### 2. Portfolio Management
- Support for multiple portfolios
- Each portfolio contains:
  - Portfolio name
  - List of cryptocurrencies with amounts
  - Total portfolio value calculation
- Portfolio operations:
  - Create new portfolio
  - Rename existing portfolio
  - Delete portfolio (preventing deletion of last portfolio)
  - Move cryptocurrencies between portfolios

### 3. Data Persistence
- Save portfolio data using SharedPreferences
- Automatic loading of saved portfolios on app start
- Automatic saving when portfolios are modified

### 4. Market Data Integration
- Real-time cryptocurrency data from multiple APIs
- Periodic updates of cryptocurrency prices
- Automatic portfolio value updates

## API Integration
- Multiple API Sources:
  - Coinpaprika API (default)
    - Comprehensive cryptocurrency data
    - Free tier with 20,000 calls/month
    - No API key required for free tier
  - CoinGecko API
    - Wide range of cryptocurrencies
    - Free tier with generous limits
    - Includes additional market data
  - CoinCap API
    - Real-time pricing data
    - WebSocket support for live updates
    - Simple and straightforward API

- User can switch between APIs via dropdown in the cryptocurrencies list view
- Each API provides:
  - Real-time cryptocurrency prices
  - 24-hour price changes
  - Market capitalization
  - Trading volume
  - Market rank

## Technical Implementation

### Models
1. **Cryptocurrency Model**
```dart
class Cryptocurrency {
  String id;
  String name;
  String symbol;
  double price;
  double percentChange24h;
  double marketCap;
  double volume24h;
  int rank;
  double amount;
}
```

2. **Portfolio Model**
```dart
class Portfolio {
  String name;
  List<Cryptocurrency> cryptocurrencies;
  double get totalValue;
}
```

### Services
1. **ApiService**
- Handles all API communications
- Provides error handling and data transformation
- Supports dependency injection for testing

### User Interface
1. **Main Screen**
- Tab-based navigation between Cryptocurrencies and Portfolio views
- Refresh button for manual data updates
- Search field for filtering cryptocurrencies

2. **Cryptocurrency Details Screen**
- Detailed view of selected cryptocurrency
- Option to add to portfolio with amount input

## Important Implementation Notes

### 1. Preserve Existing Functionality
- **CRITICAL**: Maintain all existing user interaction methods
- Keep both long-press and detail view methods for adding cryptocurrencies
- Preserve all current portfolio management features

### 2. Error Handling
- Handle API failures gracefully
- Provide feedback for all user actions
- Maintain data integrity during operations

### 3. Testing Requirements
- Unit tests for all models
- Widget tests for main UI components
- Mocked API responses for testing

## Version History

### Current Version: 1.0.0
- Initial implementation with core features
- Portfolio management
- CoinCap API integration
- Data persistence
- Unit and widget tests
