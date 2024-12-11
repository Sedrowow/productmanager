# Task 6

sql persisting & pure provider usage

## description

The next task would be to ensure that there are no more "temporary" objects, but everything that is written goes into the state.

When something is saved, it goes into the SQLite database.

Furthermore, you can take another look at Provider and see how you can replace the StreamBuilder in the screens.

Right now, you have a rather wild mix between the use of Provider and native StreamBuilders in the code.

You can also check the documentation for this:

<https://pub.dev/packages/provider>
provider | Flutter package
A wrapper around InheritedWidget to make them easier to use and more reusable.

There is some information under usage. Otherwise, also check the Flutter website.. they have also documented Provider.

## my research

### Current Issues

1. Mixed usage of StreamBuilder and Provider
2. Temporary objects that don't persist
3. Inconsistent state management

### Provider Benefits

- More efficient than StreamBuilder for UI updates
- Simpler state management
- Better performance due to reduced rebuild scope
- Built-in dependency injection

### Implementation Plan

1. State Management Changes:
   - Create dedicated providers for each data type
   - Move all temporary storage to persistent storage
   - Remove StreamBuilder usage where possible

2. Database Integration:
   - Implement immediate persistence on form submission
   - Remove temporary entry storage
   - Add SQLite database methods for CRUD operations

3. UI Updates:
   - Convert StreamBuilder widgets to Consumer widgets
   - Implement loading states for database operations
   - Add error handling for failed operations

4. Migration Steps:
   1. Create model-specific providers
   2. Implement SQLite persistence
   3. Update UI components
   4. Remove temporary storage logic
   5. Add error handling
