# Data Nexus FastAPI Backend

Backend API for Data Nexus / Central Information System.

## Setup

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

Edit `.env` with your MySQL password.

## Database setup

### MySQL

Run `database.sql` in MySQL Workbench, phpMyAdmin, or MySQL terminal.

Tables created:

- `clients`
- `organizations`

### MongoDB

Start MongoDB locally. Then seed service categories:

```powershell
python seed_mongo.py
```

MongoDB database name:

```text
data_center
```

Collections used:

- `client_profiles`
- `organization_profiles`
- `notifications`
- `categories`
- `servers`

## Run backend

```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Test

Open:

```text
http://localhost:8000
http://localhost:8000/docs
```

## Main endpoints

- `POST /client/signup`
- `POST /client/login`
- `GET /client/profile`
- `PUT /client/profile`
- `POST /organization/signup`
- `POST /organization/login`
- `GET /organization/profile`
- `PUT /organization/profile`
- `POST /server/create`
- `GET /server/`
- `GET /server/my`
- `GET /server/search?query=...`
- `GET /server/category/{category}`
- `GET /notifications/{receiver_type}/{receiver_id}`
