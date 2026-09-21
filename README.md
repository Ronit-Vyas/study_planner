# 📚 Study Planner

> A personalized mobile study-planning application built with **Flutter & Dart** that helps students organize courses, break them into topics, automatically generate study schedules, and track daily progress through an interactive calendar.

---

## 📌 Overview

**Study Planner** is a mobile application designed to help students plan and manage their academic workload efficiently.

Instead of simply storing a list of courses, the application allows users to:

* Create courses with deadlines and priorities.
* Divide each course into individual topics.
* Specify the estimated time required for each topic.
* Specify how much time they can study per day.
* Automatically generate a study schedule.
* Track daily study tasks.
* Mark completed tasks.
* Visualize progress through an interactive calendar.
* Monitor overall course and topic completion.
* Manage their account securely using authentication.

The application is being developed using **Flutter and Dart**, with **Firebase** planned for authentication and cloud data storage.

---

## 🎯 Project Goals

The primary goals of Study Planner are:

1. Help students organize their academic courses and topics.
2. Automatically distribute study workload across available days.
3. Consider course priority and deadlines while generating schedules.
4. Provide a clear daily task list.
5. Allow students to track completed work.
6. Provide visual progress through a calendar.
7. Maintain user-specific study data.
8. Provide a clean, responsive and professional mobile UI.

---

# ✨ Core Features

## 🔐 1. User Authentication

Users will be able to create and manage their accounts.

### Functional Requirements

* User registration.
* User login.
* User logout.
* Forgot-password functionality.
* Authentication state management.
* Persistent login session.
* User-specific study data.

### Planned Technology

**Firebase Authentication**

---

# 📚 2. Course Management

Users can create and manage their courses.

Each course contains information such as:

* Course name.
* Description.
* Deadline.
* Priority.
* Topics associated with the course.

### Functional Requirements

Users should be able to:

* Add a new course.
* View all courses.
* View course details.
* Edit a course.
* Delete a course.
* Set course priority.
* Set a course deadline.
* View the number of topics in a course.
* View estimated total study time.

### Example

```text
Data Structures
Priority: HIGH
Deadline: 15 September

Topics:
├── Trees              3 hrs
├── Sorting            2 hrs
├── Graphs             5 hrs
└── Dynamic Programming 6 hrs
```

---

# 📖 3. Topic Management

A course can contain multiple topics.

### Relationship

```text
Course 1 ─────────── N Topics
```

For example:

```text
Data Structures
│
├── Arrays
├── Linked Lists
├── Trees
├── Graphs
├── Sorting
└── Dynamic Programming
```

### Functional Requirements

Users should be able to:

* Add topics to a course.
* Specify the estimated study time for each topic.
* Edit topics.
* Delete topics.
* View topics belonging to a course.
* Track topic progress through scheduled tasks.

---

# 🧠 4. Automatic Study Schedule

The application will automatically generate a study schedule based on the user's available time and course information.

### Inputs

The scheduler will consider:

* Course priority.
* Course deadline.
* Topic estimated duration.
* Available study hours per day.
* Current date.
* Existing scheduled tasks.

### Example

Suppose:

```text
Course: Data Structures
Priority: HIGH
Deadline: 10 September

Available study time:
3 hours/day

Topics:
Trees       → 3 hrs
Sorting     → 2 hrs
Graphs      → 5 hrs
DP          → 6 hrs
```

The application may generate:

```text
30 Aug → Trees       → 3 hrs
31 Aug → Sorting     → 2 hrs
01 Sep → Graphs      → 3 hrs
02 Sep → Graphs      → 2 hrs
03 Sep → DP          → 3 hrs
04 Sep → DP          → 3 hrs
...
```

The scheduling algorithm will distribute the workload across available days while respecting deadlines and priorities.

---

# ✅ 5. Daily Study Tasks

The generated schedule will consist of individual study tasks.

### Relationship

```text
Course
   │
   └── Topic
         │
         └── Scheduled Tasks
```

For example:

```text
Data Structures
│
└── Graphs
     │
     ├── 01 Sep → 2 hrs
     ├── 02 Sep → 2 hrs
     └── 03 Sep → 1 hr
```

### Functional Requirements

Users should be able to:

* View today's tasks.
* View upcoming tasks.
* Mark a task as completed.
* View task duration.
* View the associated course.
* View the associated topic.
* View task status.
* Reschedule tasks when required.

---

# 📅 6. Interactive Calendar

The application will provide a calendar-based representation of the user's study schedule.

The calendar will show the user's study activity for each day.

### Example

```text
             September 2026

 Mon Tue Wed Thu Fri Sat Sun
     01  02  03  04  05  06
      ✓   ✓   ✓   ○   ○
 07  08  09  10  11  12  13
 ✓   ✓   ✗   ○
```

### Status Indicators

```text
✓  Completed
○  Scheduled
✗  Missed
```

### Functional Requirements

Users should be able to:

* Navigate between months.
* Select a specific date.
* View tasks scheduled for that date.
* Identify completed study days.
* Identify pending tasks.
* Identify missed tasks.
* View daily study workload.

---

# 📊 7. Progress Tracking

The application will provide meaningful progress information.

### Possible statistics

```text
Courses                  5
Topics                   28
Completed Tasks          42
Pending Tasks            16

Overall Progress         72%
```

### Functional Requirements

The application should calculate:

* Course completion percentage.
* Topic completion.
* Daily completion.
* Overall task completion.
* Completed study hours.
* Remaining study hours.

---

# 🏠 8. Dashboard

The Home screen will provide a quick overview of the user's study activity.

### Dashboard Components

```text
Home
│
├── Greeting
│
├── Today's Progress
│
├── Today's Tasks
│
├── Upcoming Deadlines
│
└── Overall Progress
```

The dashboard should allow users to quickly understand:

* What they need to study today.
* How much they have completed.
* Which deadlines are approaching.
* Their overall progress.

---

# 👤 9. User Profile

Users will have a dedicated profile section.

### Functional Requirements

* View profile information.
* Update profile information.
* View study statistics.
* Manage application settings.
* Logout.

---

# ⚙️ 10. Settings

The application will provide configurable settings.

Possible settings include:

* Dark mode.
* Notification preferences.
* Daily study-hour preferences.
* Account settings.
* Logout.

---

# 🔔 11. Notifications

A future version may provide study reminders.

Examples:

```text
🔔 Study Reminder

You have 2 tasks remaining today.

Graphs
2 hours
```

Notifications may also be used for:

* Upcoming deadlines.
* Scheduled study sessions.
* Incomplete tasks.
* Daily study reminders.

---

# 🏗️ Application Architecture

The application follows a modular Flutter architecture.

```text
lib/
│
├── main.dart
│
├── models/
│   ├── user_model.dart
│   ├── course_model.dart
│   ├── topic_model.dart
│   └── task_model.dart
│
├── screens/
│   ├── auth/
│   ├── home/
│   ├── courses/
│   ├── calendar/
│   ├── tasks/
│   └── profile/
│
├── widgets/
│   ├── common/
│   ├── course/
│   ├── task/
│   ├── home/
│   └── calendar/
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── scheduler_service.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── course_provider.dart
│   ├── task_provider.dart
│   └── calendar_provider.dart
│
├── routes/
│   └── app_routes.dart
│
├── utils/
│   ├── constants.dart
│   ├── helpers.dart
│   └── validators.dart
│
└── theme/
    ├── app_theme.dart
    └── app_colors.dart
```

---

# 🗂️ Data Model

The core application relationship is:

```text
User
 │
 └── Courses
       │
       └── Topics
             │
             └── Scheduled Tasks
```

### User

```text
User
├── id
├── name
└── email
```

### Course

```text
Course
├── id
├── name
├── description
├── deadline
└── priority
```

### Topic

```text
Topic
├── id
├── courseId
├── name
└── estimatedHours
```

### Study Task

```text
StudyTask
├── id
├── courseId
├── topicId
├── date
├── duration
└── completed
```

---

# ☁️ Firebase Integration

Firebase is planned as the backend platform.

### Firebase Services

#### Firebase Authentication

Used for:

* Registration.
* Login.
* Logout.
* Password recovery.
* User authentication.

#### Cloud Firestore

Used for storing:

* User information.
* Courses.
* Topics.
* Scheduled tasks.
* Completion status.

Planned conceptual structure:

```text
Firestore
│
└── users
     │
     └── userId
          │
          ├── courses
          │    └── courseId
          │
          ├── topics
          │    └── topicId
          │
          └── tasks
               └── taskId
```

---

# 🔄 Application Workflow

```text
              ┌───────────────┐
              │     Login     │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │     Home      │
              └───────┬───────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Courses     Calendar     Profile
          │
          ▼
     Add Course
          │
          ▼
      Add Topics
          │
          ▼
    Set Available Time
          │
          ▼
   Generate Schedule
          │
          ▼
    Scheduled Tasks
          │
          ▼
       Calendar
          │
          ▼
   Mark Tasks Complete
          │
          ▼
    Update Progress
```

---

# 🛠️ Technology Stack

| Technology              | Purpose                      |
| ----------------------- | ---------------------------- |
| Flutter                 | Mobile application framework |
| Dart                    | Programming language         |
| Firebase Authentication | User authentication          |
| Cloud Firestore         | Cloud database               |
| Material 3              | UI components                |
| Git                     | Version control              |
| GitHub                  | Source-code hosting          |

---

# 📱 Target Platform

The primary target is:

**Android**

The application is being developed and tested on:

**Vivo T4 5G**

The project may support other Android devices depending on screen size and Android version.

---

# 📋 Functional Requirements

## FR-01 — Authentication

The system shall allow users to:

* Register an account.
* Log in.
* Log out.
* Recover forgotten passwords.
* Maintain an authenticated session.

## FR-02 — Course Management

The system shall allow authenticated users to:

* Create courses.
* View courses.
* Edit courses.
* Delete courses.
* Assign priorities.
* Assign deadlines.

## FR-03 — Topic Management

The system shall allow users to:

* Add multiple topics to a course.
* Specify estimated time for each topic.
* Edit topics.
* Delete topics.
* View course-specific topics.

## FR-04 — Schedule Generation

The system shall:

* Calculate available study days.
* Consider the course deadline.
* Consider course priority.
* Consider estimated topic duration.
* Consider available daily study hours.
* Generate scheduled study tasks.

## FR-05 — Task Management

The system shall allow users to:

* View scheduled tasks.
* Mark tasks as completed.
* View task duration.
* View task date.
* View associated course and topic.
* Reschedule tasks where applicable.

## FR-06 — Calendar

The system shall:

* Display scheduled tasks by date.
* Display completed tasks.
* Display pending tasks.
* Display missed tasks.
* Allow users to select dates.
* Display tasks for the selected date.

## FR-07 — Progress

The system shall calculate:

* Daily progress.
* Course progress.
* Overall progress.
* Completed tasks.
* Remaining tasks.
* Completed study hours.

## FR-08 — Profile

The system shall allow users to:

* View their profile.
* Modify supported profile information.
* View study statistics.
* Access application settings.
* Log out.

## FR-09 — Data Persistence

The system shall persist authenticated users' data so that their:

* Courses.
* Topics.
* Tasks.
* Completion status.
* Progress

remain available across application sessions.

---

# 🔒 Non-Functional Requirements

### Performance

* The application should provide smooth navigation.
* UI interactions should respond quickly.
* Large task/course lists should remain usable.

### Usability

* The UI should be simple and student-friendly.
* Important information should be visible without unnecessary navigation.
* Tasks should be easy to mark as completed.

### Responsiveness

The UI should adapt to different Android screen sizes.

### Security

* Authentication should be handled securely.
* User data should be isolated between accounts.
* Sensitive credentials should not be hardcoded in the application.

### Maintainability

The codebase should use:

* Reusable widgets.
* Separate models.
* Service classes.
* Modular screens.
* Clear naming conventions.

---

# 🚧 Development Status

The project is being developed incrementally.

### Current

* [x] Flutter project created
* [x] GitHub repository created
* [x] Initial frontend structure
* [x] Navigation concept
* [ ] Complete Home UI
* [ ] Course UI
* [ ] Topic management UI
* [ ] Calendar UI
* [ ] Profile UI
* [ ] Scheduler
* [ ] Firebase Authentication
* [ ] Cloud Firestore
* [ ] Progress tracking
* [ ] Notifications

---

# 🗺️ Future Scope

Potential future improvements include:

* Smart schedule re-generation.
* Automatic rescheduling of missed tasks.
* Study streaks.
* Weekly/monthly analytics.
* Subject-wise statistics.
* Exam mode.
* Multiple study sessions per day.
* Pomodoro timer.
* Study reminders.
* Offline support.
* Cloud synchronization across devices.
* Export study schedules.
* AI-assisted study planning.

---

# 🚀 Getting Started

## Prerequisites

Install:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Git

Verify Flutter installation:

```bash
flutter doctor
```

---

## Clone the Repository

```bash
git clone <your-repository-url>
```

Navigate into the project:

```bash
cd study_planner
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 📱 Running on Android

Connect your Android device with USB debugging enabled.

Check connected devices:

```bash
flutter devices
```

Then run:

```bash
flutter run
```

The application can then be tested directly on the target Android device.

---

# 🤝 Contribution

This project is currently being developed as a personal learning and portfolio project.

Future contributions and suggestions may be considered as the project evolves.

---

# 📄 License

This project is currently intended for educational and portfolio purposes.

A formal open-source license may be added in a future release.

---

## 👨‍💻 Author

**Ronit Vyas**

B.Tech Computer Engineering

Developed using **Flutter & Dart**.

---

## ⭐ Project Vision

Study Planner aims to transform a simple list of academic courses into a **personalized, deadline-aware study plan**.

The core idea is:

```text
Courses
   ↓
Topics
   ↓
Priorities + Deadlines
   ↓
Available Study Time
   ↓
Automatic Schedule
   ↓
Daily Tasks
   ↓
Completion Tracking
   ↓
Calendar & Progress
```

> **Plan smarter. Study consistently. Track your progress.**
