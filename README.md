# ⚡ SvitloUA

> Know when the lights go out. Track power outage schedules in Ukraine.

![iOS](https://img.shields.io/badge/iOS-16%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![Xcode](https://img.shields.io/badge/Xcode-16%2B-blue?logo=xcode)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 About

**SvitloUA** is an independent iOS application for tracking power outage schedules in Ukraine. It provides real-time schedules from the official **YASNO API**, helping users plan their day around electricity availability.

> SvitloUA is not affiliated with YASNO or DTEK.

---

## ✨ Features

- ⚡ **Real-time schedules** — Up-to-date outage data from YASNO API
- 🏠 **Home Screen Widget** — Small, Medium and Large widget sizes
- 📅 **Today & Tomorrow** — View full schedule for current and next day
- 🔔 **Notifications** — Get notified before outages start
- 🌙 **Dark Mode** — Full support for light and dark themes
- 🔒 **Privacy First** — No registration, no personal data collected
- ⚙️ **Simple Setup** — Select your city and group once, app remembers settings

---

## 📸 Screenshots

| Schedule | Widget | Settings |
|----------|--------|----------|
| <img width="250" alt="Schedule" src="https://github.com/user-attachments/assets/b855af2a-4ed5-4d78-b6fe-88cf73635c04" /> | <img width="250" alt="Widget" src="https://github.com/user-attachments/assets/dec28c19-b40e-4d60-926c-de502f42b6a7" /> | <img width="250" alt="Settings" src="https://github.com/user-attachments/assets/eebb6408-09f3-4f0b-8693-3098bcdbd4b6" /> |

---

## 🏗️ Architecture

```
SvitloUA/
├── Common/
│   ├── Manager/
│   │   ├── NetworkManager.swift
│   │   ├── NotificationManager.swift
│   │   └── PowerDataManager.swift
│   ├── Models/
│   │   ├── API/
│   │   │   ├── DaySchedule.swift
│   │   │   ├── DSOData.swift
│   │   │   ├── GroupData.swift
│   │   │   ├── GroupSchedule.swift
│   │   │   ├── RegionData.swift
│   │   │   ├── RegionSchedule.swift
│   │   │   ├── ScheduleData.swift
│   │   │   └── YasnoScheduleResponse.swift
│   │   ├── Domain/
│   │   │   ├── PowerStatus.swift
│   │   │   ├── TimeSlot.swift
│   │   │   └── UserSettings.swift
│   │   └── UI/
│   │       └── YasnoComponent.swift
│   └── Network/
│       ├── Configuration/
│       │   ├── APIConfiguration.swift
│       │   └── AppEnvironment.swift
│       ├── Endpoints/
│       │   └── YasnoEndpoints.swift
│       ├── Protocols/
│       │   └── NetworkServiceProtocols.swift
│       ├── Services/
│       │   └── NetworkManager+Yasno.swift
│       └── NetworkError.swift
│
├── Screens/
│   ├── Help/
│   │   ├── Components/
│   │   │   ├── HelpSection.swift
│   │   │   ├── HelpStepCard.swift
│   │   │   ├── HelpView.swift
│   │   │   └── InfoBox.swift
│   │   └── GroupHelpView.swift
│   ├── Notifications/
│   │   └── NotificationSettingsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Schedule/
│       ├── Component/
│       │   ├── CompactScheduleCard.swift
│       │   ├── CurrentStatusCard.swift
│       │   ├── EmptyScheduleCard.swift
│       │   ├── ScheduleCard.swift
│       │   └── TimeSlotRow.swift
│       └── ScheduleView.swift
│
└── UICommon/
    └── Extensions/
        ├── Extensions+Color.swift
        ├── Extensions+Int.swift
        ├── Extensions+PowerStatus.swift
        ├── Extensions+TimeSlot.OutageType.swift
        ├── Extensions+URL.swift
        └── Extensions+View.swift

SvitloWidget/
├── View/
│   ├── LargeWidgetView.swift
│   ├── MediumWidgetView.swift
│   └── SmallWidgetView.swift
├── PowerWidget.swift
├── PowerWidgetEntry.swift
├── PowerWidgetPreviews.swift
├── PowerWidgetProvider.swift
├── PowerWidgetView.swift
└── SvitloWidget.swift
```

---

## 🌐 Data Source

All schedule data is provided by the official **YASNO API**:

```
https://api.yasno.com.ua/api/v1/
```

No API key required. Public API with no user data collection.

---

## 🔒 Privacy

SvitloUA stores only:
- Selected **city** (region)
- Selected **outage group**

Data is stored locally using **UserDefaults** with App Group (`group.ua.svitlo.app`) for widget synchronization. No data is transmitted to SvitloUA servers.

See full [Privacy Policy](https://toha-gornich.github.io/svitloua-privacy/privacy.html).

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 16.0+ |
| Xcode | 16.0+ |
| Swift | 5.9+ |
| macOS (dev) | 14.0+ |

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/toha-gornich/SvitloUA.git
cd SvitloUA
```

### 2. Open in Xcode

```bash
open SvitloUA.xcodeproj
```

### 3. Configure Signing

1. Open project settings
2. Select **SvitloUA** target
3. **Signing & Capabilities** → Set your Team
4. Update Bundle Identifier if needed

### 4. Configure App Group

Make sure App Group is enabled for both targets:
- `SvitloUA` target
- `SvitloWidgetExtension` target

App Group ID: `group.ua.svitlo.app`

### 5. Run the app

Select your device or simulator and press **Cmd + R**

---

## ⚙️ Configuration

### Supported Regions (YASNO)

| Code | City |
|------|------|
| `kyiv` | Kyiv / Київ |


### Outage Groups

Groups: `1.1`, `1.2`, `2.1`, `2.2`, `3.1`, `3.2`, `4.1`, `4.2`, `5.1`, `5.2`, `6.1`, `6.2`

---

## 📦 App Store

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/svitloua)

- **Version:** 1.0.0
- **Price:** Free
- **Category:** Utilities
- **Age Rating:** 4+

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Anton Hornich**

- Email: toha.gornich@gmail.com
- GitHub: [@toha-gornich](https://github.com/toha-gornich)

---

## 🙏 Acknowledgements

- [YASNO](https://yasno.com.ua) for providing public API
- Apple WidgetKit documentation
- Ukrainian developer community 🇺🇦

---

<p align="center">
  Made with ❤️ in Ukraine 🇺🇦
</p>
