# 프로젝트 디렉토리 구조

<pre>
DevOps/
├── nodeJs/
│   ├── notification/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── notification.js
│   ├── post/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── post.js
│   ├── user/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── user.js
│   └── docker-compose.yml
│
├── k8s/
│   ├── user/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── post/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── notification/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── ingress.yaml
│
└── .github/
    └── workflows/
        └── deploy.yml
</pre>
