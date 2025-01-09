# Crypto Portfolio Tracker Refactoring Plan

## Phase 1: Foundation and Models
### Step 1: Setup Testing Environment ⏳
- [ ] Add test dependencies to pubspec.yaml
  ```yaml
  dev_dependencies:
    flutter_test:
      sdk: flutter
    mockito: ^5.4.2
    build_runner: ^2.4.6
  ```
- [ ] Create test directory structure
  ```
  test/
  ├── models/
  ├── services/
  ├── widgets/
  └── helpers/
  ```
- [ ] Create mock data helpers

### Step 2: Model Layer Refactoring ⏳
- [ ] Move Portfolio class to lib/models/portfolio.dart
  - [ ] Add JSON serialization
  - [ ] Write unit tests:
    ```dart
    test('Portfolio serialization', () {
      final portfolio = Portfolio(...);
      final json = portfolio.toJson();
      final decoded = Portfolio.fromJson(json);
      expect(decoded.name, equals(portfolio.name));
    });
    ```
- [ ] Enhance Cryptocurrency model
  - [ ] Add validation
  - [ ] Complete serialization tests
  - [ ] Test value calculations

## Phase 2: Service Layer Implementation
### Step 3: API Service ⏳
- [ ] Create lib/services/api_service.dart
  ```dart
  abstract class ApiService {
    Future<List<Cryptocurrency>> fetchCryptoData();
  }
  ```
- [ ] Implement CoinMarketCap service
- [ ] Write tests with mocked HTTP client:
  ```dart
  test('fetchCryptoData returns parsed data', () async {
    final service = MockApiService();
    final cryptos = await service.fetchCryptoData();
    expect(cryptos, isNotEmpty);
  });
  ```

### Step 4: Storage Service ⏳
- [ ] Create lib/services/storage_service.dart
- [ ] Implement SharedPreferences wrapper
- [ ] Write tests with mocked SharedPreferences
- [ ] Test portfolio persistence

### Step 5: Portfolio Service ⏳
- [ ] Create lib/services/portfolio_service.dart
- [ ] Move portfolio management logic from _CryptoListScreenState
- [ ] Implement CRUD operations
- [ ] Write comprehensive tests

## Phase 3: State Management
### Step 6: Provider Implementation ⏳
- [ ] Add provider package
- [ ] Create portfolio provider
- [ ] Create crypto list provider
- [ ] Write widget tests with providers:
  ```dart
  testWidgets('Portfolio provider updates UI', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PortfolioProvider(),
        child: TestApp(),
      ),
    );
    // Test UI updates
  });
  ```

### Step 7: Widget Refactoring ⏳
- [ ] Create lib/widgets/portfolio_selector.dart
- [ ] Create lib/widgets/crypto_list_item.dart
- [ ] Create lib/widgets/add_to_portfolio_dialog.dart
- [ ] Write widget tests for each component

## Phase 4: Screen Organization
### Step 8: Screen Restructuring ⏳
- [ ] Create lib/screens/crypto_list/
  - [ ] Move list screen logic
  - [ ] Split into smaller widgets
- [ ] Create lib/screens/portfolio/
- [ ] Write integration tests

### Step 9: Error Handling ⏳
- [ ] Create lib/utils/error_handler.dart
- [ ] Implement error reporting
- [ ] Add error boundary widgets
- [ ] Test error scenarios

## Phase 5: Final Touches
### Step 10: Configuration ⏳
- [ ] Create lib/config/
  - [ ] api_config.dart
  - [ ] theme_config.dart
  - [ ] string_constants.dart
- [ ] Update imports to use configurations
- [ ] Test configuration loading

### Step 11: Documentation ⏳
- [ ] Add dartdoc comments
- [ ] Create API documentation
- [ ] Update README.md

## Testing Guidelines
1. **Unit Tests**
   - Every new class/service must have unit tests
   - Target 80%+ code coverage
   - Test edge cases and error scenarios

2. **Widget Tests**
   - Test widget rendering
   - Test user interactions
   - Test state updates

3. **Integration Tests**
   - Test full user flows
   - Test data persistence
   - Test network interactions

## Progress Tracking
- ✅ = Complete
- ⏳ = In Progress
- ❌ = Failed/Needs Revision

## Implementation Notes
1. Each step should be a separate branch
2. Create PR for each completed step
3. Run full test suite before merging
4. Update documentation with changes
5. Keep commits atomic and well-documented

## Rollback Plan
- Each phase has a stable checkpoint
- Maintain working code in main branch
- Document any breaking changes
- Keep backup of working state
