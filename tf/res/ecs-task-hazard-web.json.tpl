[
  {
    "name": "hazard-web",
    "image": "${IMAGE}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "environment": [
      { "name": "REACT_APP_API_BASE_URL", "value": "${REACT_APP_API_BASE_URL}" }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${LOG_GROUP}",
          "awslogs-region": "${AWS_REGION}",
          "awslogs-stream-prefix": "ecs"
        }
    }
  }
]
