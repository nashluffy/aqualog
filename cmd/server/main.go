package main

import (
	"context"
	"fmt"
	"log"
	"log/slog"
	"net"

	life "github.com/Nashluffy/aqualog/gen/go/life"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct {
	life.UnimplementedLifeServer
}

func (s *server) GetByID(ctx context.Context, req *life.GetByIDRequest) (*life.GetByIDResponse, error) {
	res := fmt.Sprintf("arghhhhh: %d", req.GetId())
	getFishByID(int(req.GetId()))
	slog.Info("req received", "species", req.GetId())
	return &life.GetByIDResponse{Name: &res}, nil
}

func main() {
	lis, err := net.Listen("tcp", "127.0.0.1:50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()

	life.RegisterLifeServer(s, &server{})
	reflection.Register(s)

	fmt.Println("Server is running on port 50051...")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func getFishByID(fishID int) {
}
