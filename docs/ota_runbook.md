# OTA Update Runbook

This document outlines the architecture, security measures, and operational procedures for the new Over-the-Air (OTA) update system for the Openly app.

## 1. Architecture

The new OTA system is designed to be secure, resilient, and flexible. It consists of three main components:

1.  **Release Metadata (`releases.json`):** A JSON file that serves as the "backend" for the OTA system. It contains a list of all available releases, with metadata for each release. This file is hosted in the root of the application's Git repository.
2.  **CI/CD Workflow (`.github/workflows/create_release.yml`):** A GitHub Actions workflow that automates the release process. It builds a signed APK, generates a signature, updates the `releases.json` file, and creates a GitHub Release.
3.  **Flutter Client (`lib/services/update_service.dart`):** The Flutter service responsible for checking for updates, validating them, and handling the download and installation process.

## 2. Security

Security is a core principle of the new OTA system. The following measures have been implemented:

*   **Signature Validation:** Every APK is signed with a SHA256 hash. The signature is stored in the `releases.json` metadata file. The Flutter client downloads the APK, calculates its signature, and compares it with the one in the metadata. The installation only proceeds if the signatures match. This prevents man-in-the-middle (MITM) attacks.
*   **Secure Metadata Source:** The `releases.json` file is hosted in a private Git repository, which provides a secure and auditable source of truth for updates.

## 3. Operations Runbook

### 3.1 Creating a New Release

To create a new release, follow these steps:

1.  Ensure your `main` branch is up to date and contains all the changes you want to release.
2.  Go to the "Actions" tab in the GitHub repository.
3.  Select the "Create Secure Release" workflow.
4.  Click the "Run workflow" button.
5.  Enter the `version` (e.g., `1.5.0`) and `changelog` for the release.
6.  Click the "Run workflow" button to start the release process.

The workflow will automatically build the app, sign it, update the `releases.json` file, and create a new GitHub Release with the signed APK.

### 3.2 Staged Rollouts

The `releases.json` file supports staged rollouts. To release an update to a percentage of users, set the `rolloutPercentage` field in the new release entry to a value between 0 and 100. For example, to release to 25% of users, set it to `25`.

### 3.3 Forced Updates

The `releases.json` file also supports forced updates. To force users to update to a critical version, set the `isForced` field in the new release entry to `true`. This will show a non-dismissible dialog to the user, requiring them to update.

## 4. Future Improvements

The current OTA system is a robust foundation, but it can be extended with the following features:

*   **Rollback Support:** To support rolling back a bad release, you could publish a new release with the old APK and an incremented `buildNumber`. A more sophisticated approach would involve adding a `isRollback` flag to the metadata and handling it in the client.
*   **Localization and UI:** The update dialog is currently in English only. The strings can be extracted and localized using Flutter's internationalization tools. The UI can also be further improved to match the Material 3 design guidelines.
*   **Production Telemetry:** The current telemetry uses `debugPrint`. This should be replaced with a proper analytics service (e.g., Firebase Analytics, Sentry) to collect data in a production environment.
