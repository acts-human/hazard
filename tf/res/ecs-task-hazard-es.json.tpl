[
  {
    "name": "hazard-es",
    "image": "${IMAGE}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 9200,
        "hostPort": 9200,
        "protocol": "tcp"
      },
      {
        "hostPort": 9300,
        "containerPort": 9300,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${LOG_GROUP}",
        "awslogs-region": "${AWS_REGION}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      },
      {
        "name": "memlock",
        "softLimit": -1,
        "hardLimit": -1
      }
    ],
    "cpu": 1024,
    "memory": 2048,
    "environment": [
      { "name": "cluster.name", "value": "hazard" },
      { "name": "bootstrap.memory_lock", "value": "true" },
      { "name": "ES_JAVA_OPTS", "value": "-Xms512m -Xmx512m -XX:UseAVX=1" },
      { "name": "discovery.type", "value": "single-node" },
      { "name": "http.cors.enabled", "value": "true" },
      { "name": "http.cors.allow-origin", "value": "*" },
      { "name": "http.cors.allow-methods", "value": "OPTIONS,HEAD,GET,POST,PUT,DELETE" },
      { "name": "http.cors.allow-headers", "value": "X-Requested-With,X-Auth-Token,Content-Type,Content-Length" },
      { "name": "http.cors.allow-credentials", "value": "true" }
    ]
  }
]
