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
	aqualog "github.com/Nashluffy/aqualog/gen/go/life"
	life "github.com/Nashluffy/aqualog/gen/go/life"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct {
	life.UnimplementedLifeServer
	speciesFetcher species.Fetcher
}

func (s *server) GetByID(ctx context.Context, req *life.GetByIDRequest) (*life.GetByIDResponse, error) {
	allSpecies, err := s.speciesFetcher.GetByIDs([]int{int(req.GetId())})
	if err != nil {
		slog.Warn(err.Error())
		return nil, err
	}
	if len(allSpecies) != 1 {
		return nil, fmt.Errorf("unexpected number of species returned: %d", len(allSpecies))
	}
	species := allSpecies[0]
	n := fmt.Sprintf("%d", species)
	return &aqualog.GetByIDResponse{Species: &aqualog.SpeciesInformation{
		Id:       &n,
		Comments: &species.Comments.String,
	}}, nil
}

func (s *server) GetByCommonName(ctx context.Context, req *life.GetByCommonNameRequest) (*life.GetByCommonNameResponse, error) {
	species, err := s.speciesFetcher.GetByCommonName(req.GetName())
	if err != nil {
		slog.Warn(err.Error())
		return nil, err
	}
	var results []*aqualog.SpeciesInformation
	for _, specie := range species {
		n := fmt.Sprintf("%d", species)
		results = append(results, &aqualog.SpeciesInformation{
			Id:       &n,
			Comments: &specie.Comments.String,
		})
	}
	return &life.GetByCommonNameResponse{Species: results}, nil
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

	speciesFetcher := species.NewFetcher(db, "https://fishbase.ropensci.org/fishbase", "https://fishbase.ropensci.org/sealifebase")
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
