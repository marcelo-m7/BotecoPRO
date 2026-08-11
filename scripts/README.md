# BotecoPRO developer toolchain

This directory is the canonical orchestration layer for repository validation.
Flutter/Dart remain responsible for application, widget and integration tests;
Python handles diagnosis, process execution, Android devices/emulators, evidence
and reports. The root Makefile is the short public interface.

## First use

Run the read-only diagnosis first:

```bash
make doctor
make bootstrap
make verify
```

`bootstrap.sh` resolves the repository root, requires Python 3.10+, creates or
reuses `.tools/devtools-venv`, and installs the pinned requirements file. The
current CLI has no third-party Python runtime dependency; the requirements file
is deliberately empty. It never installs Python packages globally and never
installs Flutter, Java, Android SDK components or system images silently.

The normative versions live in `scripts/toolchain.json`. Android device shape,
locale and API live in `scripts/profiles/android.json`. The API 36/minSdk 24
values are the defaults exposed by the pinned Flutter 3.44.9 Gradle plugin used
by the actual mobile project. AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14.3 and Java
17 come from its checked-in Android configuration. Build-tools remain managed
by AGP because the project does not pin a version.

## Command contract

The full interface is `python scripts/botecopro.py <command> --help`. Common
entry points are:

```bash
make doctor
make tooling-test
make mobile-check
make android-doctor
make android-build
make android-smoke
make android-integration
make android-evidence
make evidence-audit
make verify
```

All Flutter commands run from `apps/mobile` even when called elsewhere. The
runner records command, working directory, UTC start, duration and exit code.
It captures stdout/stderr without suppressing failures and redacts secret-like
CLI arguments. It never dumps the process environment.

The format gate covers the connected M0–M7 source directories and all current
tests. Older explicitly isolated demo/legacy UI files retain pre-existing
format debt and remain covered by analyzer/tests without being reformatted as
part of this infrastructure milestone.

## Physical Android device

Enable developer options and USB debugging, connect the device, then run:

```bash
make android-doctor
python scripts/botecopro.py android-smoke --device SERIAL
```

If exactly one ready device exists, `make android-smoke` selects it. If more
than one exists, selection is intentionally rejected until `--device SERIAL`
is supplied. `--uninstall-after` is the only path that removes the development
APK. `--reset-app-data` explicitly erases only `com.example.botecopro` local
development data.

## Emulator

Normal commands never download or create a system image. Create the canonical
AVD explicitly with Android Studio or `sdkmanager`/`avdmanager` using the values
in `scripts/profiles/android.json`, then run:

```bash
sdkmanager "platform-tools" "platforms;android-36" "emulator" \
  "system-images;android-36;google_apis;x86_64"
printf 'no\n' | avdmanager create avd \
  --name botecopro_pixel_api_36 \
  --package "system-images;android-36;google_apis;x86_64" \
  --device pixel_6
make android-doctor
python scripts/botecopro.py android-smoke --avd botecopro_pixel_api_36
```

The CLI reuses a matching running AVD without stopping it. Otherwise, it starts
the requested existing AVD, waits for `sys.boot_completed`, applies the fixed
display profile and disables animations, and stops only that process. On Linux,
missing/inaccessible `/dev/kvm` fails immediately with a recommendation to use
a physical device or the GitHub Actions Android workflow.

## Android integration

`make android-integration` runs the supported Flutter `integration_test`
journey on a selected device or the canonical AVD. It starts at the real
connection gate, uses the real pages/providers/storage with a deterministic
read-only synthetic Odoo HTTP client, exercises connected catalog/cart,
transport-level offline fallback and complete app-tree recreation, then
reconnects. The fixture cannot execute an Odoo write and never uses `.env.local`
or the normal application storage keys.

For repeatability checks:

```bash
make android-integration ANDROID_REPEAT=3
```

The first attempt builds the integration APK; subsequent attempts reinstall
that exact binary after clearing the development package. A failed attempt
stops the sequence but retains its partial screenshots, driver output and
logcat. Recreating the complete Flutter app/provider tree validates storage
recovery; Android process `force-stop` recovery remains a separate future
hardening check.

## Evidence

`make android-evidence` performs the full synthetic Android integration journey
and writes to:

```text
.artifacts/evidence/<RUN_ID>/
├── environment.json
├── integration-response.json
├── logcat.txt
├── manifest.json
├── report.json
├── report.md
├── test-results.json
├── driver-output.txt
├── screenshots/
│   ├── 01-connected-home.png
│   ├── 02-catalog.png
│   ├── ...
│   └── 09-restored-cart.png
└── repeats/                  # present when ANDROID_REPEAT > 1
```

The manifest records repository/mobile SHAs, tool versions, Android metadata,
classification, scenario/attempt status and each PNG's
SHA-256/timestamp/asserted scenario step.
Text artifacts are scanned for obvious Authorization, bearer, cookie, token and
API-key patterns before a synthetic run passes.

Real capture is always explicit:

```bash
python scripts/botecopro.py android-evidence \
  --evidence-source real --device SERIAL
```

`REAL_INSTANCE` images always remain `CAPTURED_REVIEW_REQUIRED`. Text scanning
and OCR cannot guarantee image safety, so a human must inspect every real image.
Capture does not publish; `.artifacts/` is ignored and CI only uploads artifacts.
Credentials, `.env.local`, secure storage contents and raw request headers must
never be included.

## CI

The normal Flutter workflow reads versions from `toolchain.json`, bootstraps the
same venv and runs `make doctor` plus `make verify`. The separate Android
workflow uses a KVM-backed GitHub emulator, invokes
`make android-evidence ANDROID_REPEAT=3`, and uploads the APK and ignored
evidence directory for 14 days even when the scenario fails. It never commits
generated evidence and has no Odoo credentials.

## Troubleshooting

- **Flutter missing/mismatch:** install the exact version in `toolchain.json`,
  add it to `PATH` or set `FLUTTER_ROOT`, then rerun `make doctor`.
- **Java mismatch:** select a Java 17 JDK via `JAVA_HOME` and `PATH`.
- **Android SDK missing:** install command-line tools/platform 36 and compatible
  build-tools, then set `ANDROID_SDK_ROOT` (or `ANDROID_HOME`).
- **No adb device:** authorize USB debugging and inspect `adb devices -l`.
- **No AVD:** create the named profile explicitly; commands do not download
  large system images on demand.
- **KVM unavailable:** use a physical device or dispatch Android Evidence CI.
- **Boot timeout:** inspect `.artifacts/emulator.log`; confirm KVM and AVD API.
- **APK install failure:** check free space, device authorization and Android
  API; rerun with `--verbose`. Existing app data is preserved by smoke.
- **App crash:** inspect the run-local `logcat.txt` under
  `.artifacts/android-smoke/` or `.artifacts/evidence/`.
