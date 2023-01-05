package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

// Todo is a struct that represents a todo item
type Todo struct {
	ID          int64  `json:"id"`
	Description string `json:"description"`
	Completed   bool   `json:"completed"`
}

func getTodos(svc *dynamodb.DynamoDB) ([]Todo, error) {
	// Query the DynamoDB table to retrieve all todo items
	result, err := svc.Scan(&dynamodb.ScanInput{
		TableName: aws.String("Todos"),
	})
	if err != nil {
		return nil, err
	}

	// Unmarshal the DynamoDB item values into a slice of Todo structs
	var todos []Todo
	for _, i := range result.Items {
		var todo Todo
		err = dynamodbattribute.UnmarshalMap(i, &todo)
		if err != nil {
			return nil, err
		}
		todos = append(todos, todo)
	}

	return todos, nil
}

func main() {
	lambda.Start(func(ctx context.Context) (string, error) {
		// Create a DynamoDB client
		sess, err := session.NewSession()
		if err != nil {
			return "", err
		}
		svc := dynamodb.New(sess)

		// Get all todo items
		todos, err := getTodos(svc)
		if err != nil {
			return "", err
		}

		// Print the todo items
		for _, todo := range todos {
			fmt.Printf("Todo: %s\n", todo.Description)
		}

		return "Success", nil
	})
}
