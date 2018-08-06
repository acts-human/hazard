[
  {
    "name": "hazard-api",
    "image": "${IMAGE}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 10010,
        "hostPort": 10010
      }
    ],
    "environment": [
      { "name": "ES_HOST", "value": "${ES_HOST}" }
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
