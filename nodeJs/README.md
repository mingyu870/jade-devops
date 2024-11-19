DevOps/
└── nodeJs/
    ├── notification/
    │   ├── Dockerfile
    │   ├── package.json
    │   └── notification.js
    ├── post/
    │   ├── Dockerfile
    │   ├── package.json
    │   └── post.js
    ├── user/
    │   ├── Dockerfile
    │   ├── package.json
    │   └── user.js
    ├── docker-compose.yml          
    ├── k8s/                       # Kubernetes 매니페스트 파일 디렉토리
    │   ├── user/
    │   │   ├── deployment.yaml    # user 서비스의 Kubernetes 배포 매니페스트
    │   │   └── service.yaml       # user 서비스의 Kubernetes 서비스 매니페스트
    │   ├── post/
    │   │   ├── deployment.yaml    # post 서비스의 Kubernetes 배포 매니페스트
    │   │   └── service.yaml       # post 서비스의 Kubernetes 서비스 매니페스트
    │   ├── notification/
    │   │   ├── deployment.yaml    # notification 서비스의 Kubernetes 배포 매니페스트
    │   │   └── service.yaml       # notification 서비스의 Kubernetes 서비스 매니페스트
    │   └── ingress.yaml           # Ingress 설정 
    └── .github/
        └── workflows/
            └── deploy.yml         # k8s CI/CD 자동화 배포 설정
