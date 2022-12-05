package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
)

type Environment struct {
	TagList []string `json:"Tags"`
}

var client *ec2.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("eu-west-1"))
	if err != nil {
		panic("configuration error, " + err.Error())
	}

	client = ec2.NewFromConfig(cfg)
}

func HandleRequest(environment Environment) ([]string, error) {
	var result, err = client.DescribeInstances(context.TODO(), &ec2.DescribeInstancesInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("tag:Env"),
				Values: environment.TagList,
			},
		},
	})
	if err != nil {
		return []string{}, err
	}

	var status, toStartIds, toStopIds []string

	for _, r := range result.Reservations {
		for _, i := range r.Instances {
			if i.State.Name == "running" {
				status = append(status, fmt.Sprintf("Changing InstanceID: %v from %v to stopped", *i.InstanceId, i.State.Name))
				toStopIds = append(toStopIds, *i.InstanceId)
			} else if i.State.Name == "stopped" {
				status = append(status, fmt.Sprintf("Changing InstanceID: %v from %v to running", *i.InstanceId, i.State.Name))
				toStartIds = append(toStartIds, *i.InstanceId)
			}
		}
	}

	var _, startErr = client.StartInstances(context.TODO(), &ec2.StartInstancesInput{InstanceIds: toStartIds})
	if startErr != nil {
		return []string{}, startErr
	}

	var _, stopErr = client.StopInstances(context.TODO(), &ec2.StopInstancesInput{InstanceIds: toStopIds})
	if stopErr != nil {
		return []string{}, stopErr
	}

	return status, nil
}

func main() {
	lambda.Start(HandleRequest)
}
