# 프로젝트 디렉토리 구조

<pre>
DevOps/
├── nodeJs/
│   ├── argocd/
│   │   └── argocd.yaml
│   ├── helm/
│   │   ├── templates/
│   │   │   ├── deployment.yaml
│   │   │   ├── ingress.yaml
│   │   │   └── service.yaml
│   │   ├── Chart.yaml
│   │   └── values.yaml
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
└── .github/
    └── workflows/
        ├── notification-deploy.yaml
        ├── post-deploy.yaml
        └── user-deploy.yaml
</pre>

