package main

import (
	"context"
	"fmt"
	"log"
	"log/slog"
	"net"

	"database/sql"

	_ "github.com/marcboeker/go-duckdb"

	"github.com/Nashluffy/aqualog/backend/pkg/species"
	life "github.com/Nashluffy/aqualog/gen/go/life"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct {
	life.UnimplementedLifeServer
	speciesFetcher species.Fetcher
}

func (s *server) GetByID(ctx context.Context, req *life.GetByIDRequest) (*life.GetByIDResponse, error) {
	species, err := s.speciesFetcher.GetByID(int(req.GetId()))
	if err != nil {
		slog.Warn(err.Error())
		return nil, nil
	}
	n := fmt.Sprintf("%d", species.SpecCode)
	return &life.GetByIDResponse{Name: &n, Comments: &species.Comments}, nil
}

func main() {
	lis, err := net.Listen("tcp", "127.0.0.1:50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()

	db, err := sql.Open("duckdb", "")
	if err != nil {
		log.Fatalf("Failed to open DuckDB: %v", err)
	}
	defer db.Close()

	speciesFetcher := species.NewFetcher(db, "https://fishbase.ropensci.org/fishbase/species.parquet")
	server := &server{
		speciesFetcher: speciesFetcher,
	}

	life.RegisterLifeServer(s, server)
	reflection.Register(s)

	fmt.Println("Server is running on port 50051...")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
