# Pre-Change Checklist

Before implementing any changes, verify:

## 1. Change Request Analysis
- [ ] Is the change request specific and clear?
- [ ] Are there any ambiguities that need clarification?
- [ ] Have I identified all components that might be affected?

## 2. Critical Component Review
- [ ] Have I reviewed the critical_components.md file?
- [ ] Will this change affect any critical components?
- [ ] If yes, is there explicit permission to modify them?

## 3. Existing Functionality
- [ ] Have I documented all current working features in the affected area?
- [ ] Do I understand how these features are implemented?
- [ ] Have I planned how to preserve all existing functionality?

## 4. Implementation Plan
- [ ] Can I implement the change without modifying working code?
- [ ] If not, do I have explicit permission to modify working code?
- [ ] Have I planned how to isolate the changes?

## 5. Testing Strategy
- [ ] Have I listed all features that need to be tested after the change?
- [ ] Do I have a plan to verify all existing functionality remains intact?
- [ ] Have I documented any potential side effects?

## Post-Change Verification
After implementing changes, verify:

## 1. UI Components
- [ ] All columns and layouts remain intact
- [ ] All interaction methods (long-press, tap) work
- [ ] Data formatting is preserved
- [ ] Search functionality works

## 2. Portfolio Features
- [ ] Long-press to add works
- [ ] Detail view add works
- [ ] Portfolio selection works
- [ ] Amount input works
- [ ] Data persistence works

## 3. Data Display
- [ ] All numeric formatting is correct
- [ ] All columns show correct data
- [ ] Color coding works
- [ ] Sort functionality (if any) works

## 4. Error Handling
- [ ] All error cases are handled
- [ ] User feedback is preserved
- [ ] Data validation works

## Documentation
- [ ] Changes are documented
- [ ] Critical component documentation is updated if needed
- [ ] Any new features are documented
