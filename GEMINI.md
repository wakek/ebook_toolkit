# Ebook Toolkit Codebase Context

This document defines the architectural patterns, key dependencies, and domain-specific knowledge required to effectively work on the **Ebook Toolkit** project.

## 1. Project Overview

**Ebook Toolkit** is a Dart/Flutter library (forked from `epubx`) designed for parsing and writing EPUB files and reading PDF files. It provides a robust set of domain models and utilities for ebook manipulation.

### Directory Structure
*   **`lib/`**: The core library source code.
    *   **`src/epub/`**: EPUB-specific logic, including entities, readers, writers, and schema definitions.
    *   **`src/pdf/`**: PDF-specific domain models.
    *   **`src/utils/`**: Shared utilities like `ZipPathUtils`.
*   **`android/`**: Android-specific implementation, including C++ helpers for direct memory access.
*   **`test/`**: Comprehensive unit tests for EPUB parsing, writing, and schema validation.
*   **`example/`**: Sample applications demonstrating usage in Flutter, pure Dart, and Web environments.

---

## 2. Core Architecture

The project follows a modular architecture separating data representation from parsing/writing logic.

### EPUB Module (`lib/src/epub/`)
The EPUB implementation is the most mature part of the toolkit.

*   **Entities** (`entities/`): Plain Dart objects representing the domain (e.g., `EpubBook`, `EpubChapter`).
*   **Ref Entities** (`ref_entities/`): Lazy-loading wrappers around EPUB content. `EpubBookRef` allows accessing metadata and structure without loading all content into memory immediately.
*   **Readers** (`readers/`): Responsible for parsing EPUB XML files (OPF, NCX) and extract data from the ZIP archive.
*   **Writers** (`writers/`): Logic for generating EPUB XML and packing it into a compliant ZIP archive.
*   **Schema** (`schema/`): Deep mapping of the EPUB standard XML structures, specifically **OPF** (Open Packaging Format) and **Navigation** (NCX).

### PDF Module (`lib/src/pdf/`)
Currently, PDF support is focused on reading and is mediated via native code.

*   **Entities** (`pdf/entities/`): Models like `PdfDocument` and `PdfPage`.
*   **Reader** (`pdf_reader.dart`): Interfaces with platform-specific code via `MethodChannel`.

### Platform Integration
*   **Android**: Uses JNI (`android/c++/directBufferAndroid.cpp`) to handle direct byte buffers, optimizing performance for large file processing.

---

## 3. Key Libraries & Dependencies

| Library | Usage |
| :--- | :--- |
| **`archive`** | Core dependency for ZIP decoding/encoding (EPUB format). |
| **`xml`** | Used for parsing and generating the internal XML files of an EPUB. |
| **`equatable`** | Used in entities to simplify object comparisons. |
| **`image`** | Used for handling book cover images. |
| **`plugin_platform_interface`** | Standard Flutter plugin architecture for platform-specific PDF features. |

---

## 4. Coding Standards

1.  **Strict Linting**: The project uses `very_good_analysis` for high-quality code standards.
2.  **Immutability**: Entities prefer immutable patterns, often leveraging `equatable`.
3.  **Validation**: All schema-related changes should be accompanied by tests in `test/schema/` to ensure compliance with the EPUB standard.

---

## 5. Common Tasks

### Reading an EPUB
```dart
// Load metadata only (Fast)
EpubBookRef bookRef = await EpubReader().openBook(bytes);

// Load the entire book into memory
EpubBook book = await EpubReader().readBook(bytes);
```

### Writing an EPUB
```dart
List<int>? bytes = EpubWriter().writeBook(myEpubBookObject);
```

### Reading a PDF (Flutter only)
```dart
PdfDocument doc = await PdfReader().loadPdfFromPath(filePath);
```

---

## 6. Maintenance of this Document

Evolve this file as the toolkit expands, particularly when adding new ebook format support or refactoring the core reader/writer pipelines.
