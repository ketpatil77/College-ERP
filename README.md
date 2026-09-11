# 🎓 College ERP System

A Django-based college management platform that brings common academic and administrative workflows into one web application for administrators, staff, and students.

## Overview

College ERP provides role-based access to student and staff workflows such as student management, attendance, results, leave requests, feedback, profiles, and dashboard reporting.

## Core Features

### Admin

- Manage students, staff, courses, subjects, and academic sessions
- Review attendance, leave requests, and feedback
- View dashboard analytics

### Staff

- Record and update attendance
- Enter and manage examination results
- Submit leave applications and feedback
- View relevant student and subject information

### Students

- View attendance and examination results
- Submit leave requests
- Manage profile information
- Provide feedback to administration

## Technology Stack

| Layer | Technology |
|---|---|
| Backend | Python, Django |
| Frontend | HTML, CSS, JavaScript, Bootstrap |
| Database | SQLite for development; PostgreSQL can be used for deployment |
| Authentication | Django authentication |
| Deployment | PythonAnywhere or another Django-compatible host |

## Local Setup

### Requirements

- Git
- Python 3.11 or compatible Python 3 release
- pip

### Clone the repository

```bash
git clone https://github.com/ketpatil77/College-ERP.git
cd College-ERP
```

### Create and activate a virtual environment

Windows:

```bash
python -m venv venv
venv\Scripts\activate
```

macOS/Linux:

```bash
python3 -m venv venv
source venv/bin/activate
```

### Install dependencies

```bash
pip install -r requirements.txt
```

### Configure the application

Set the environment variables required by the deployment, such as the Django secret key, allowed hosts, and email settings. Do not commit real secrets.

For local demo credentials, use the repository's example credentials file and keep the real local credentials file ignored by Git.

### Initialize the database

```bash
python manage.py migrate
python manage.py createsuperuser
```

### Run the development server

```bash
python manage.py runserver
```

Open <http://127.0.0.1:8000>.

The repository also provides `START.bat` and `START.sh` launch helpers where supported.

## Project Documentation

- [Architecture overview](docs/architecture.md)

## Screenshots

Screenshots are available under [`Showcase/`](Showcase/) in the repository.

## Roadmap

Planned or optional extensions include SMS notifications, advanced reporting, online examinations, library management, fee integration, timetable generation, and a parent portal.

## Contributing

1. Fork the repository.
2. Create a focused feature or fix branch.
3. Make and test your changes.
4. Commit with a clear message.
5. Open a pull request with a concise description of the change.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

## Contact

- GitHub: <https://github.com/ketpatil77>
- Email: <mailto:ket.patil77@gmail.com>
- Issues: <https://github.com/ketpatil77/College-ERP/issues>
