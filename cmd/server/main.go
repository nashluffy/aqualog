package main

import (
	"context"
	"fmt"
	"log"
	"net"

	life "github.com/Nashluffy/aqualog/gen/go/life"
	"google.golang.org/grpc"
)

type server struct {
	life.UnimplementedLifeServer
}

func (s *server) GetByID(ctx context.Context, req *life.GetByIDRequest) (*life.GetByIDResponse, error) {
	res := fmt.Sprintf("req id: %d", req.GetId())
	return &life.GetByIDResponse{Name: &res}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()

	life.RegisterLifeServer(s, &server{})

	fmt.Println("Server is running on port 50051...")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
