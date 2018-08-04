[
  {
    "name": "hazard-web",
    "image": "${IMAGE}",
    "networkMode": "awsvpc",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 22,
        "hostPort": 22
      },
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]

  }
]
