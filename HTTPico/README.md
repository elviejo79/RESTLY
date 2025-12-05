# RESTFUL Library

A RESTful API library for Eiffel with example application and comprehensive test suite.

## Project Structure

This project is organized with multiple compilation targets to support different use cases:

```
RESTFUL/
├── src/                    # Library source code
├── example/               # Example application demonstrating library usage
├── tests/                 # AutoTest test suite
└── restful.ecf              # Single configuration file with multiple targets
```

## Compilation Targets

The project uses multiple compilation targets defined in `restful.ecf`:

### 1. Library Target (`library`)
Compiles only the library classes for use as a reusable component.

**Usage:**
Only available within EiffelStudio for library development. Use the standalone `restful_library.ecf` for external projects.

**What it includes:**
- All classes in `src/` directory
- Excludes test classes and example application
- Produces a library that can be referenced by other projects

### 2. Example Application Target (`example`)
Compiles the library with an example application that demonstrates its usage.

**Usage:**
```bash
ec -config restful.ecf -target example -clean -compile
```

<old_text>
**Usage:**
```bash
ec -config restful_multi_target.ecf -target development -clean -compile
```

**What it includes:**
- All library classes from `src/`
- Example application from `example/`
- Produces executable: `restful_example`

**Running the example:**
```bash
./EIFGENs/example/W_code/restful_example
```

### 3. Testing Target (`testing`)
Compiles the library with test classes for AutoTest execution.

**Usage:**
Only available within EiffelStudio. Open `restful.ecf` and select the testing target.

**Running AutoTest:**
1. Open `restful_multi_target.ecf` in EiffelStudio
2. Select the "testing" target when prompted
3. Go to Project > AutoTest > Run All Tests

**What it includes:**
- All library classes from `src/`
- All test classes from `tests/`
- EiffelBase testing library

### 4. Development Target (`development`)
Includes everything for comprehensive development work.

**Usage:**
```bash
ec -config restful_multi_target.ecf -target development -clean -compile
```

**What it includes:**
- All library classes
- Example application
- Test classes
- Useful during development when you need access to all components

## Using Different Targets in EiffelStudio

1. **Open the project:** File > Open > Select `restful.ecf`
2. **Choose target:** EiffelStudio will prompt you to select a target:
   - **library**: For library development
   - **example**: To run the example application
   - **testing**: To run AutoTest suite
   - **development**: For comprehensive development with all components
3. **Switch targets:** Project > Project Settings > Target (dropdown)

## Using the Library in Other Projects

To use the RESTFUL library in your own Eiffel projects:

1. Reference the library ECF file in your project:
   ```xml
   <library name="restful" location="path/to/restful_library.ecf"/>
   ```

2. Or specify the library target explicitly:
   ```xml
   <library name="restful" location="path/to/restful.ecf" target="library"/>
   ```

<old_text>
1. Reference the library ECF file in your project:
   ```xml
   <library name="restful" location="path/to/restful_library.ecf"/>
   ```

2. Or specify the library target explicitly:
   ```xml
   <library name="restful" location="path/to/restful.ecf" target="library"/>
   ```

## Library Features

The RESTFUL library provides:

- **REST_TABLE**: Hash table implementation for REST endpoint management
- **RESOURCE_TABLE**: Shared resource management across different URLs
- **URL handling**: URL parsing and manipulation classes
- **HTTP client integration**: Built-in support for HTTP operations
- **JSON support**: JSON parsing and generation capabilities

## Running Tests

To run the AutoTest suite:

1. Open `restful_multi_target.ecf` in EiffelStudio
2. Select the "testing" target when prompted
3. Wait for compilation to complete
4. Go to Project > AutoTest
5. Click "Run All Tests"

**Note:** Testing target is only available within EiffelStudio, not from command line.

## Example Usage

See the example application in `example/application.e` for demonstrations of:

- Creating and using REST_TABLE instances
- Working with RESOURCE_TABLE for shared resources
- URL manipulation and handling

## Dependencies

- EiffelBase
- HTTP Client library
- JSON library
- URI library
- Time library
- Testing library (for test target only)

## Compilation Targets Benefits

Using multiple compilation targets provides several advantages:

1. **Clean separation of concerns**: Library, examples, and tests are clearly separated
2. **Flexible deployment**: Can compile just the library for production use
3. **Easy testing**: Dedicated target for running AutoTest within EiffelStudio
4. **Development efficiency**: Development target includes everything for comprehensive work
5. **Reduced dependencies**: Each target only includes necessary libraries
6. **Proper encapsulation**: Library consumers only see the library interface, not internal tests or examples

## Migration from Single Target

## Why Only One ECF File?

You might wonder why we don't need separate ECF files for different purposes. Here's why **one multi-target ECF file is better**:

### ❌ **Old Approach (Multiple Files)**
```
restful_library.ecf        # Library only
restful_application.ecf    # Application only  
restful_testing.ecf        # Testing only
```

**Problems:**
- Configuration duplication across files
- Hard to maintain consistency
- Confusing for users - which file to use?
- Changes need to be made in multiple places

### ✅ **New Approach (Single Multi-Target File)**
```
restful.ecf               # One file, multiple targets
├── library target        # Library classes only
├── example target        # Library + example app
├── testing target        # Library + tests
└── restful target        # Default (same as example)
```

**Benefits:**
- Single source of truth for configuration
- Shared common settings via inheritance
- Easy to maintain and understand
- Users reference one file with different targets

The multi-target approach is the **modern Eiffel best practice** and eliminates the need for multiple ECF files.

## Summary

**Compilation Targets** in Eiffel allow you to:
- Define different compilation configurations for the same codebase
- Include/exclude different sets of classes based on usage
- Specify different root classes for executable targets
- Use different library dependencies per target
- Maintain clean separation between library code, examples, and tests

This approach enables you to have a single codebase that can be compiled as:
- A reusable library (for other projects to consume)
- An example application (demonstrating library usage)
- A test suite (for AutoTest execution)
- A development environment (with all components available)