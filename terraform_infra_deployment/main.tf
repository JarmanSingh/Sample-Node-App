provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

resource "aws_ecr_repository" "node_api" {
  name = "node-api"
}

resource "aws_ecs_cluster" "node_api" {
  name = "node-api" # Naming the cluster
}

resource "aws_ecs_task_definition" "node_api" {
    container_definitions    = jsonencode(
        [
            {
                cpu          = 0
                environment  = []
                essential    = true
                image        = ""
                memory       = 128
                mountPoints  = []
                name         = "node-api"
                portMappings = [
                    {
                        containerPort = 8080
                        hostPort      = 80
                        protocol      = "tcp"
                    },
                ]
                volumesFrom  = []
            },
        ]
    )
    family                   = "node-api"
    requires_compatibilities = [
        "EC2",
    ]
    tags                     = {}
    tags_all                 = {}
}

resource "aws_ecs_service" "node_api" {
  name            = "node-api"                             # Naming our first service
  cluster         = "${aws_ecs_cluster.node_api.id}"             # Referencing our created Cluster
  task_definition = "node-api:4" # Referencing the task our service will spin up
  launch_type     = "EC2"
  desired_count   = 1 # Setting the number of containers to 1
  wait_for_steady_state = null
  enable_ecs_managed_tags =  true
  ordered_placement_strategy {
        field = "attribute:ecs.availability-zone"
        type  = "spread"
    }
    ordered_placement_strategy {
        field = "instanceId"
        type  = "spread"
    }
}

# aws_codepipeline.node_app_pipeline:
resource "aws_codepipeline" "node_app_pipeline" {
    name     = "express-sample-app-pipeline"
    role_arn = ""
    tags     = {}

    artifact_store {
        location = ""
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            category         = "Source"
            configuration    = {
                "BranchName"           = "main"
                "FullRepositoryId"     = "JarmanSingh/Sample-Node-App"
                "OutputArtifactFormat" = "CODE_ZIP"
            }
            input_artifacts  = []
            name             = "Source"
            namespace        = "SourceVariables"
            output_artifacts = [
                "SourceArtifact",
            ]
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            region           = "us-east-1"
            run_order        = 1
            version          = "1"
        }
    }
    stage {
        name = "expres-test-app-build"

        action {
            category         = "Build"
            configuration    = {
                "EnvironmentVariables" = jsonencode(
                    [
                        {
                            name  = "AWS_ACCOUNT_ID"
                            type  = "PLAINTEXT"
                            value = ""
                        },
                        {
                            name  = "DOCKER_USERNAME"
                            type  = "PLAINTEXT"
                            value = ""
                        },
                        {
                            name  = "DOCKER_PASSWORD"
                            type  = "PLAINTEXT"
                            value = ""
                        },
                    ]
                )
                "ProjectName"          = "express-test-app"
            }
            input_artifacts  = [
                "SourceArtifact",
            ]
            name             = "express-test-app-building"
            output_artifacts = [
                "imagedefinitions",
            ]
            owner            = "AWS"
            provider         = "CodeBuild"
            region           = "us-east-1"
            run_order        = 1
            version          = "1"
        }
    }
    stage {
        name = "deploy"

        action {
            category         = "Deploy"
            configuration    = {
                "ClusterName" = "node-api"
                "FileName"    = "imagedefinitions.json"
                "ServiceName" = "node-api"
            }
            input_artifacts  = [
                "imagedefinitions",
            ]
            name             = "deploy"
            output_artifacts = []
            owner            = "AWS"
            provider         = "ECS"
            run_order        = 1
            version          = "1"
        }
    }
}


