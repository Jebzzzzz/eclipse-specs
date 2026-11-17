# Business Logic

> Development of a Web-Based OJT Documentation and Manuscript Preparation System using React and Supabase for On-the-Job Training Students

- Allowed Platforms: Web

## Project Details

- Company/Startup/Team Name: Noecier
- Project Code Name: Eclipse
- Project Short Code: ECL
- Short Description: A web-based platform for OJT students to document workplace activities, record hours, upload evidence, and prepare internship manuscripts with AI-assisted writing support.
- Long Description: OJT Chronicle is a web application designed for on-the-job training students who need to maintain clear, organized, and credible documentation during their internship or practicum. The system allows students to log daily work activities, record working hours, upload supporting screenshots or files, and write narrative reflections that can later be structured into manuscripts or final internship reports. Supervisors and administrators can review documentation, provide feedback, and monitor progress while students retain control over their original entries and revision history.

## User Levels

| User Level                           | Description                                                                                     |
| ------------------------------------ | ----------------------------------------------------------------------------------------------- |
| A. System Administrator              | Manages system settings, user roles, backups, and overall platform administration.              |
| B. Academic Supervisor / Coordinator | Reviews student documentation, provides feedback, and monitors internship progress.             |
| C. OJT Student                       | Records daily activities, uploads evidence, writes reflections, and prepares manuscript drafts. |
| D. Faculty Reviewer                  | Checks final submissions, validates completion requirements, and supports evaluation.           |
| E. Guest                             | Users who do not log in but may view public or limited informational content if enabled.        |

## System Requirements

1. The app shall allow users to authenticate using Google Sign-In integration.
2. The app shall allow OJT students to create, update, and delete daily activity logs and work-hour entries.
3. The app shall allow students to upload supporting files, screenshots, and images as evidence for assigned tasks and accomplishments.
4. The app shall allow students to write original OJT descriptions, reflections, and narrative entries with timestamped revisions.
5. The app shall allow students to request AI-assisted grammar, clarity, and readability improvements while preserving the original content.
6. The app shall allow supervisors and reviewers to view student entries, provide comments, and track compliance with internship requirements.
7. The app shall allow administrators and faculty to generate reports, monitor progress, and export documentation for evaluation or submission.
8. The app shall allow students to organize entries into manuscript sections or report-ready formats based on approved academic structure.

## Required Solution Layers

1. Security and privacy by design. Access control, role-based permissions, secure authentication, no unauthorized exposure of student data, and retention limits for uploads and records.
2. Data integrity and versioning. Timestamped submissions, revision history, and preserved original content for audit and academic compliance.
3. AI-assisted writing support. Clear separation between original text and enhanced text, with user-controlled acceptance of improvements.
4. Reporting and export readiness. Structured presentation of internship activity records and manuscript drafts in a format suitable for faculty review and final submission.

## MVP Features and Access

> See the User Levels table for reference.

| Feature                                                                   | Access  |
| ------------------------------------------------------------------------- | ------- |
| 1. User authentication, profile setup, and session management             | A,B,C,D |
| 2. Daily activity logs and work-hour tracking                             | C       |
| 3. Evidence uploads and supporting document management                    | C       |
| 4. Original writing, drafts, and revision history                         | C       |
| 5. AI-assisted grammar and clarity enhancement                            | B,C,D   |
| 6. Supervisor and faculty review comments and evaluation status           | B,C,D   |
| 7. Administrative reporting, user management, and export of documentation | A,B     |

## Notes

- The MVP focuses on documentation, evidence tracking, revision control, and AI-assisted writing support for OJT students.
- Automated manuscript generation beyond structured drafting and export is not assumed as part of the initial release unless formally approved.
- Public guest access remains optional and should be limited to informational content only, not student records or private internship data.
