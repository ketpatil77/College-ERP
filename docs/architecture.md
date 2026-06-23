# Architecture Overview

## Purpose

College ERP is a Django-based institutional application for academic administration, staff workflows, student access, attendance, results, leave, and feedback.

## System Shape

```text
Admin / Staff / Student
  -> Django views and templates
  -> role-based workflows
  -> database models
  -> attendance, results, leave, feedback, dashboards
```

## Application Layers

- Django project settings and routing define app configuration.
- Views handle role-specific workflows for admin, staff, and students.
- Templates render dashboards, forms, tables, and status pages.
- Models persist academic entities and workflow records.
- Static assets support dashboard and responsive UI behavior.

## Role Flows

### Admin

- Manage staff, students, courses, subjects, sessions, attendance, leave, and feedback.

### Staff

- Mark attendance, enter results, submit leave requests, and send feedback.

### Student

- View attendance, results, leave status, and submit feedback.

## Design Goals

- Keep academic operations in one unified system.
- Separate user roles clearly.
- Make local setup reproducible with documented startup commands.
- Keep demo credentials and production credentials separated.

## Operational Notes

- Use environment variables for secrets and deployment settings.
- Keep local credential files out of Git.
- Run migrations before first local use.
