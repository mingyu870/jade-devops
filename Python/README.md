<pre>
DevOps/
└── Python/
    ├── notification.py
    ├── post.py
    ├── user.py
    ├── README.md
    ├── requirements.txt
    └── docker-compose.yml          
</pre>



## curl command 
curl -X POST http://127.0.0.1:5001/users -H "Content-Type: application/json" -d '{"name": "John", "email": "john@example.com"}'

curl -X GET http://127.0.0.1:5001/users/1
curl -X GET http://127.0.0.1:5001/users

curl -X POST http://127.0.0.1:5002/login \
-H "Content-Type: application/json" \
-d '{"username": "admin", "password": "password"}'

curl -X POST http://127.0.0.1:5003/notify \
-H "Content-Type: application/json" \
-d '{"userId": 1, "title": "New Post Notification"}'


