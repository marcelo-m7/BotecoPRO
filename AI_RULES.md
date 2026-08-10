# 🎯 AI_RULES.md - AI Collaboration Framework for BotecoPro

## 🎭 Project Partners & Roles

### 🤖 AI Agent Types

**Code Generation Agent:**
- **Role**: Generate new features, components, and business logic
- **Responsibilities**:
  - Follow established architecture patterns
  - Maintain code consistency with existing codebase
  - Implement proper error handling and validation
  - Write comprehensive unit and widget tests
- **Guidelines**:
  - Always review existing code before implementing
  - Use established naming conventions and patterns
  - Ensure reactive UI updates work correctly
  - Test all changes thoroughly

**Documentation Agent:**
- **Role**: Maintain and update project documentation
- **Responsibilities**:
  - Keep all documentation current and accurate
  - Update cross-references between documents
  - Maintain consistent formatting and structure
  - Add new documentation for new features
- **Guidelines**:
  - Review all affected documents when making changes
  - Ensure links and references are working
  - Follow established documentation patterns
  - Update version numbers and dates appropriately

**Testing Agent:**
- **Role**: Ensure code quality through comprehensive testing
- **Responsibilities**:
  - Write unit tests for all new business logic
  - Create widget tests for UI components
  - Maintain test coverage above 80%
  - Run integration tests for critical paths
- **Guidelines**:
  - Test edge cases and error conditions
  - Mock external dependencies appropriately
  - Ensure tests are fast and reliable
  - Update tests when refactoring existing code

**Architecture Agent:**
- **Role**: Maintain system architecture and design patterns
- **Responsibilities**:
  - Review proposed changes for architectural consistency
  - Suggest improvements to system design
  - Document architectural decisions
  - Ensure scalability and maintainability
- **Guidelines**:
  - Consider long-term implications of changes
  - Balance technical debt with feature delivery
  - Document trade-offs and decisions
  - Review for security and performance impacts

## 🔗 Component Partnerships

### Data Layer Components

**DatabaseService ↔ SharedPreferences:**
- **Contract**: DatabaseService manages all data persistence through SharedPreferences
- **Responsibilities**:
  - DatabaseService: CRUD operations, caching, write locks
  - SharedPreferences: Low-level key-value storage
- **Collaboration Rules**:
  - DatabaseService handles all JSON serialization/deserialization
  - SharedPreferences accessed only through DatabaseService
  - No direct SharedPreferences usage in UI components

**Models ↔ DatabaseService:**
- **Contract**: Models provide serialization, DatabaseService manages persistence
- **Responsibilities**:
  - Models: `fromJson()`, `toJson()`, `copyWith()`, validation
  - DatabaseService: Storage, retrieval, change notifications
- **Collaboration Rules**:
  - Models never access storage directly
  - DatabaseService uses model serialization methods
  - Changes to models require DatabaseService updates

### UI Layer Components

**Pages ↔ DatabaseService:**
- **Contract**: Pages display data, DatabaseService provides reactive streams
- **Responsibilities**:
  - Pages: UI rendering, user interaction, state management
  - DatabaseService: Data provision, change notifications
- **Collaboration Rules**:
  - Pages subscribe to DatabaseService changes stream
  - All data mutations go through DatabaseService
  - Pages handle loading and error states appropriately

**Widgets ↔ Pages:**
- **Contract**: Widgets are reusable components, Pages provide context
- **Responsibilities**:
  - Widgets: Generic UI components, theming
  - Pages: Business logic, data binding, navigation
- **Collaboration Rules**:
  - Widgets receive data through parameters
  - Pages handle widget callbacks and state updates
  - Shared widgets in `shared_widgets.dart` for consistency

### Navigation Components

**NavigationTab ↔ IndexedStack:**
- **Contract**: NavigationTab defines routes, IndexedStack manages display
- **Responsibilities**:
  - NavigationTab: Route definitions, icons, labels
  - IndexedStack: Page switching, state preservation
- **Collaboration Rules**:
  - Navigation changes update IndexedStack index
  - Page state preserved during navigation
  - Home page reload triggered on tab selection

## 🤝 Collaboration Protocols

### Code Review Process

**Pre-Implementation Checklist:**
- [ ] Review existing similar implementations
- [ ] Check architectural consistency
- [ ] Verify test coverage for new code
- [ ] Update documentation if needed
- [ ] Consider edge cases and error handling

**Implementation Standards:**
- [ ] Follow established naming conventions
- [ ] Use proper error handling patterns
- [ ] Implement reactive UI updates
- [ ] Add comprehensive logging
- [ ] Write tests for all new functionality

**Post-Implementation Validation:**
- [ ] Run full test suite
- [ ] Verify UI updates work correctly
- [ ] Test on different screen sizes
- [ ] Check browser console for errors
- [ ] Validate data persistence

### Communication Guidelines

**When Making Changes:**
1. **Assess Impact**: Determine which components are affected
2. **Document Changes**: Update relevant documentation
3. **Notify Partners**: Ensure dependent components are updated
4. **Test Integration**: Verify all partnerships still work
5. **Update Contracts**: Modify interfaces if necessary

**Change Categories:**

**Breaking Changes:**
- Require coordination with all affected partners
- Update documentation immediately
- Provide migration guide if needed
- Test all dependent components

**Additive Changes:**
- Maintain backward compatibility
- Update documentation
- Notify partners of new capabilities
- Test integration points

**Internal Changes:**
- Maintain existing contracts
- Update implementation details
- Test thoroughly
- Document if behavior changes

### Quality Assurance

**Automated Checks:**
- Flutter analyze passes with no errors
- All tests pass (unit, widget, integration)
- Code formatting follows dart format
- Documentation builds without warnings

**Manual Review:**
- UI works on desktop and mobile
- Data persists correctly across sessions
- Error states handled gracefully
- Performance acceptable (< 2s load time)

**Integration Testing:**
- Order creation and completion flow
- Table status transitions
- Inventory management
- Sales reporting accuracy

## 🎯 Decision Framework

### When to Use DatabaseService
- ✅ Any data persistence operation
- ✅ When data changes need to trigger UI updates
- ✅ For complex business logic involving multiple entities
- ✅ When atomic operations are required

### When to Create New Components
- ✅ When functionality is reusable across pages
- ✅ When component has its own state management
- ✅ When component is complex (> 200 lines)
- ✅ When component needs its own testing

### When to Modify Existing Architecture
- ✅ When current architecture causes significant issues
- ✅ When new requirements can't be met with current design
- ✅ When performance improvements justify changes
- ✅ When maintainability is severely impacted

### When to Add Dependencies
- ✅ When functionality is not achievable with existing code
- ✅ When dependency is well-maintained and widely used
- ✅ When dependency supports web platform
- ✅ When benefits outweigh maintenance cost

## 🚨 Emergency Protocols

### Breaking Changes Detected
1. **Stop Implementation**: Halt all related work
2. **Assess Impact**: Identify all affected components
3. **Create Rollback Plan**: Ensure ability to revert
4. **Coordinate Fix**: Work with all affected partners
5. **Test Thoroughly**: Validate fix before proceeding

### Data Corruption Issues
1. **Isolate Problem**: Prevent further corruption
2. **Backup Data**: Preserve existing data if possible
3. **Fix Root Cause**: Address underlying issue
4. **Validate Recovery**: Test data integrity
5. **Monitor Closely**: Watch for recurrence

### Performance Degradation
1. **Identify Bottleneck**: Profile and measure
2. **Implement Fix**: Optimize problematic code
3. **Test Performance**: Validate improvement
4. **Monitor Metrics**: Track ongoing performance
5. **Document Changes**: Update performance guidelines

## 📊 Success Metrics

### Code Quality
- **Test Coverage**: > 80% for business logic
- **Lint Score**: 0 errors, < 5 warnings
- **Cyclomatic Complexity**: < 10 per method
- **Documentation Coverage**: 100% for public APIs

### Performance
- **Initial Load Time**: < 2 seconds
- **UI Responsiveness**: < 100ms for interactions
- **Memory Usage**: < 50MB for typical usage
- **Storage Efficiency**: < 10MB for 1 year of data

### User Experience
- **Data Persistence**: 100% reliability
- **UI Updates**: Immediate on data changes
- **Error Recovery**: Graceful handling
- **Responsive Design**: Works on all screen sizes

### Development Velocity
- **Build Time**: < 30 seconds for incremental
- **Test Execution**: < 2 minutes for full suite
- **Deployment**: < 5 minutes to production
- **Documentation**: Updated within 1 day of changes

---

**Last Updated**: November 2, 2025
**Version**: 1.1.0
**Purpose**: Guide AI collaboration and maintain system integrity</content>
<parameter name="filePath">c:\Users\marce\Desktop\Monynha Sotwares\Codebase\BotecoPro\AI_RULES.md