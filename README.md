# 👋 Project Langfens - Testing Guide

This document provides instructions on how to configure and run the test suite on **Windows** and **Linux** environments.

## 🛠 Prerequisites
Ensure you have the following installed:
1.  **Docker Desktop** (with Docker Compose)
2.  **.NET 8.0 SDK**
3.  **Node.js 18+ & npm** (for Frontend E2E)
4.  **Git Bash** (Recommended for Windows)

---

## ⚙️ Environment Configuration

### 🐧 For Linux / macOS
1.  **Permissions**: Ensure all test scripts are executable.
    ```bash
    chmod +x *.sh
    ```
2.  **Docker**: Ensure your current user is in the `docker` group (so you don't need `sudo`).

### 🪟 For Windows Users
**⚠️ IMPORTANT:** This project uses resource-intensive containers like **Elasticsearch**, which can cause tests to fail on Windows if not configured correctly.

1.  **Use WSL2 (Recommended)**:
    *   Running scripts directly in Git Bash or PowerShell on Windows can be slow due to file system differences.
    *   **Pro Tip:** Clone and run this project inside a **WSL2 (Ubuntu)** distribution for best performance.

2.  **Increase Docker RAM**:
    *   Open **Docker Desktop** → **Settings** → **Resources**.
    *   Set **Memory Limit** to at least **4GB** (Elasticsearch alone requires ~2GB).
    *   *Symptom of low RAM:* Tests fail randomly with `Connection Refused` or containers crash with exit code 137.

3.  **Line Endings (LF vs CRLF)**:
    *   Shell scripts (`.sh`) **MUST** use LF line endings.
    *   If you see `\r: command not found` errors, convert the files:
        ```bash
        # In Git Bash
        dos2unix *.sh
        ```

---

## 🚀 Running Tests

### Option 1: The Master Script (Recommended)
We provide a unified runner for all test types:
```bash
./test-runner.sh
```
*Select option 4 to run the Full System Check.*

### Option 2: Running Individually

#### 1. Unit Tests (Backend)
Test business logic in isolation. **Fast execution.**
```bash
./run-unit-tests.sh
```

#### 2. Integration Tests (Backend)
Test database interactions, caching, and auth flows.
*   **Requires Docker**: This script handles spinning up `db`, `redis`, etc.
*   *Note:* First run may take time to pull images.
```bash
./run-integration-tests.sh
```

#### 3. E2E Tests (Frontend - Playwright)
Test full user scenarios (Login, Learn Flashcards, Take Exam).
```bash
# Run all tests in Headless mode (CI style)
./run-frontend-tests.sh 2

# Run visually (opens browser window)
./run-frontend-tests.sh 3
```

---

## 🐞 Troubleshooting

| Issue | Environment | Solution |
| :--- | :--- | :--- |
| **"Elasticsearch exited with code 137"** | Windows/Docker | Out of Memory. Increase Docker Desktop RAM to 4GB+. |
| **"Permission denied"** | Linux/Mac | Run `chmod +x *.sh`. |
| **Tests pass on Linux but fail on Windows** | Windows | Likely Docker I/O slowness. Try increasing timeouts in `playwright.config.ts`, or switch to WSL2. |
| **"Host not found" in Integration Tests** | All | Ensure ports `5432` (Postgres), `6379` (Redis), `9200` (Elastic) are not occupied by local services. |
