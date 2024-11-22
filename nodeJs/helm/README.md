# local Test
curl -X POST http://localhost:3001/users \
    -H "Content-Type: application/json" \
    -d '{"name": "John", "email": "john@example.com"}'

curl -X POST http://localhost:3002/notify \
    -H "Content-Type: application/json" \
    -d '{"userId": 1, "title": "New Post Notification"}'

curl -X POST http://localhost:3003/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "password"}'


# cluster Test
curl -X POST http://user-service:3001/users \
    -H "Content-Type: application/json" \
    -d '{"name": "John", "email": "john@example.com"}'

curl -X POST http://post-service:3002/notify \
    -H "Content-Type: application/json" \
    -d '{"userId": 1, "title": "Test Post", "content": "Hello from cluster!"}'

curl -X POST http://notification-service:3003/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "password"}'
