# User Test
curl -X POST http://microservices.local/user -H "Content-Type: application/json" -d '{"name": "John", "email": "john@example.com"}'
curl http://microservices.local/user/users

# Post Test
curl -X POST http://microservices.local/post/notify -H "Content-Type: application/json" -d '{"userId": 1, "title": "Test Post", "content": "This is a test."}'

# Notification Test
curl -X POST http://microservices.local/notification/login -H "Content-Type: application/json" -d '{"username": "admin", "password": "password"}'
curl -X GET http://microservices.local/notification/protected -H "Authorization: Bearer <TOKEN>"


# local Test
curl -X POST http://localhost:8081/users -H "Content-Type: application/json" -d '{"name": "John", "email": "john@example.com"}'

