# Business Logic v1.1 Proposed

> Status: Proposed MVP refinement
> Scope: Eclipse / OJT Chronicle
> Platform: Responsive web app (PWA); native Android is out of scope for the initial release

## 1. Product Positioning

OJT Chronicle is a single-user, student-first documentation system for internship work. It helps an OJT student capture daily activities, record hours, attach evidence, write original reflections, and keep a defensible record that can later be prepared into a final manuscript.

This product is not a collaboration platform or a general internship management suite. Its core value is simple: reduce the friction of documenting OJT work while preserving evidence, original writing, and revision history.

### Value proposition

- Students can log work consistently without juggling separate notes, screenshots, and spreadsheets.
- The app keeps a clear history of what happened, when it happened, and what evidence supports it.
- AI support focuses only on writing clarity and grammar, without replacing the student's original work.
- The final record is structured enough to support academic review and export.

### Core user problem

Students often lose track of daily work details, evidence, and written reflections. Without a single system, records become fragmented, hard to verify, and difficult to turn into a final internship report.

## 2. Gaps in the Current MVP Draft

The existing business logic is directionally sound, but it still does not define a realistic MVP boundary. The most important gaps are:

1. It mixes a student-first MVP with future reviewer/admin workflows.
   - The README explicitly states that the MVP is a personal, single-user workflow. Reviewer and administrator roles remain future and optional.

2. It does not clearly define the actual user journey.
   - The spec names features, but it does not explain the end-to-end sequence a student follows day to day.

3. It does not distinguish MVP must-haves from future enhancements.
   - Features such as multi-role review, manuscript auto-generation, and large-scale platform administration should not be considered part of the launch scope.

4. It lacks concise acceptance criteria.
   - Without a definition of done, it is hard to know when the product is valuable enough to release.

5. It is too broad for a faster time-to-market.
   - The current draft is trying to cover review, supervision, export, manuscript planning, and advanced AI in one release.

6. It does not explicitly align with the README’s constraints.
   - The README says the initial assumption is a single-user personal documentation workflow and that reviewer status is not part of the MVP.

## 3. MVP Goal

The MVP should support one essential workflow:

Student records work -> uploads evidence -> writes original reflection -> optionally requests AI clarity improvement -> keeps original and revised history -> exports or submits final documentation.

Anything beyond this should be deferred until the product proves traction.

## 4. Target User and Role Model

### Primary user: OJT student

The MVP should focus on a single user: the OJT student.

Required needs:

- log daily activities and hours
- attach screenshots or files as evidence
- write original reflections and activity descriptions
- preserve original content and revision history
- request grammar/clarity improvements without overwriting the original
- review progress and prepare a final documentation package

### Optional future roles

These roles should remain explicitly out of scope for the initial launch:

- Academic supervisor / coordinator
- Faculty reviewer
- Administrator with shared operational permissions

The README clearly supports this: reviewer and administrator functions are future, optional, and not part of the MVP.

## 5. MVP Scope: Lean and Launchable

The following feature set is the recommended MVP.

### 5.1 Authentication and profile setup

- Google Sign-In
- student account creation and session management
- basic profile fields such as name, school/program, and OJT details

### 5.2 Daily activity and work-hour logging

- create and edit daily OJT entries
- record date, title, description, and hours worked
- view entries in chronological order
- delete or archive own entries

### 5.3 Evidence uploads

- upload screenshots and supporting files
- attach files to a specific activity
- preview uploaded images
- store files in a secure private bucket

### 5.4 Original writing and revision history

- write original descriptions and reflections
- preserve original text
- maintain timestamped revisions
- allow the student to review and recover prior versions

### 5.5 AI-assisted writing support

- improve grammar or clarity for text already written by the user
- keep original copy intact
- require explicit acceptance before replacement
- record AI-assisted revision status and timestamps

### 5.6 Export and submission readiness

- generate a simple report-ready summary of activity records
- prepare documentation for academic review or final submission
- avoid automatic manuscript generation in the MVP

## 6. Subsections to Strengthen the Business Logic

### 6.1 User stories

- As a student, I want to log my daily internship work so my documentation stays accurate.
- As a student, I want to attach evidence so my entries are backed by proof.
- As a student, I want to preserve my original writing while using AI suggestions for clarity.
- As a student, I want to view my activity timeline so I can monitor my OJT progress.
- As a student, I want to export my records so I can prepare my final academic submission.

### 6.2 Core workflow

1. Student signs in.
2. Student creates a new activity entry.
3. Student records the date, title, hours, and activity details.
4. Student uploads supporting screenshots or files.
5. Student writes the original reflection or description.
6. Student requests AI grammar/clarity improvement.
7. Student reviews and accepts or discards the generated suggestion.
8. Student keeps the record as part of their final OJT documentation.
9. Student exports the final summary or report-ready record.

### 6.3 Functional requirements by role

#### Student

- Create, edit, archive, and delete own entries
- Upload and attach evidence
- Write original text and retain revision history
- Request AI writing assistance
- Export or review own documentation

#### Future reviewer roles

- Not included in the MVP
- To be considered only after the single-user workflow is stable

#### Future admin roles

- Not included in the MVP
- Define only after the product has a production need

### 6.4 Privacy, auditability, and compliance expectations

- All records must belong to an authenticated user.
- Original content must never be overwritten without an explicit decision.
- Revision history must include timestamps.
- Uploaded files must be private and access-controlled.
- AI enhancement must remain assistive and user-approved.
- Sensitive employer or student information must not be uploaded without consent.

### 6.5 Non-functional requirements

- Responsive for desktop and mobile use
- Clear loading, success, and error states
- Server-side access control through Supabase RLS and storage policies
- Reasonable upload limits and validation
- Fast, low-friction entry logging for a student working in the field

## 7. MVP Definition of Done

The MVP is complete when all of the following work end-to-end:

- a student can sign in and create a valid activity entry
- the student can record hours and a description for a workday
- the student can upload and attach evidence
- the student can preserve original writing while using AI suggestions
- the student can view a timeline or summary of records
- the student can export a report-ready record for academic use
- safeguards prevent unauthorized access to private files and records

## 8. Out of Scope for the Initial Release

To keep time-to-market fast, the following should be deferred:

- native Android app
- reviewer/supervisor portal
- faculty approval workflow
- admin dashboard and multi-role governance
- auto-generated manuscript from raw entries
- complex analytics dashboards
- real-time collaborative editing
- external integrations beyond the core app
- advanced AI features beyond grammar and clarity assistance

These are good future product bets, but they should not block the first MVP.

## 9. Recommended Positioning Statement

OJT Chronicle is a practical documentation tool for OJT students who need to record daily work, keep evidence, preserve original reflections, and prepare a final internship report with less effort and more clarity.

## 10. Recommendation

The MVP should stay student-first and intentionally lean. The product’s strongest market fit is not broad internship management; it is helping one student keep accurate, auditable, and exportable documentation from day one. That keeps the release focused, reduces complexity, and improves the odds of a faster time-to-market.

This proposal aligns with the README’s direction: a single-user documentation workflow, private-by-default records, text-based AI assistance, and export-ready documentation without overbuilding the platform before the core problem is solved.
