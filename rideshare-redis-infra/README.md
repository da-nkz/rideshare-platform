Swiftride Services Monorepo

This repository contains all backend microservices and frontend for the Swiftride platform.

Each service is independent, stateless, and can be started in any order.
Shared infrastructure (Redis, databases, etc.) is managed separately.

📁 Folder Structure
swiftride/
├── infra/
│   └── docker-compose.redis.yml
│
├── rideshare-frontend/
├── rideshare-driver-service/
├── rideshare-rider-service/
├── rideshare-trip-service/
├── rideshare-matching-service/
├── rideshare-email-service/


Architecture Overview
Each service:
- Has its own Dockerfile
- Has its own docker-compose.yml
- Does NOT own shared infrastructure
- Redis is a shared infrastructure service
- All services connect to Redis over a shared Docker network


IMPORTANT: Start Redis First
Before starting any service, you must start Redis.
Redis lives in the infra folder and is shared by all services.

1️⃣ Start Redis (one-time or once per machine restart)
cd infra
docker compose -f docker-compose.redis.yml up 

Verify Redis is running:
docker ps

You should see:
swiftride-redis


🔌 Shared Network
All services and Redis communicate via a shared Docker network:
swiftride-net
This network is created by the infra setup and reused by all services.

🚀 Starting Any Service
After Redis is running, you can start any service independently.
Example (Driver Service):
cd rideshare-driver-service
docker compose up
You can do the same for:
- rider-service
- trip-service
- matching-service
- email-service

Order does not matter.

🔐 Environment Variables
Each service must have a .env file containing Redis connection details:
- REDIS_HOST=swiftride-redis
- REDIS_PORT=6379
- REDIS_PASSWORD=yourpassword
The REDIS_HOST must match the Redis container name

🧪 Migrations
Some services include a migration container (e.g. *-migrate):
- Runs once on startup
- Exits automatically
- Uses the same image as the main service
- No manual action is required.
