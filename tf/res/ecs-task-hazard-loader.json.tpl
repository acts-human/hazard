[
  {
    "name": "hazard-loader",
    "image": "${IMAGE}",
    "essential": true,
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
