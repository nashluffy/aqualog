package main

import (
	"context"
	"fmt"
	"log"
	"log/slog"
	"net"
	"os"

	"database/sql"

	"github.com/google/uuid"
	_ "github.com/marcboeker/go-duckdb"

	"github.com/Nashluffy/aqualog/backend/pkg/species"
	"github.com/Nashluffy/aqualog/backend/pkg/storage"
	marine "github.com/Nashluffy/aqualog/gen/go/marine"
	"github.com/Nashluffy/aqualog/gen/go/records"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct {
	marine.UnimplementedCatalogueServer
	records.UnimplementedStorageServer
	speciesFetcher species.Fetcher
	recordReader   storage.Reader
	recordWriter   storage.Writer
}

// ReadRecord implements records.CatalogueServer.
func (s *server) ReadRecord(ctx context.Context, req *records.ReadRecordRequest) (*records.ReadRecordResponse, error) {
	r, err := s.recordReader.Read(req.GetId())
	if err != nil {
		slog.Warn(err.Error())
		return nil, fmt.Errorf("no record found: %w", err.Error())
	}
	return &records.ReadRecordResponse{Record: &r}, nil
}

func (s *server) GetByID(ctx context.Context, req *marine.GetByIDRequest) (*marine.GetByIDResponse, error) {
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
	return &marine.GetByIDResponse{Species: &marine.SpeciesInformation{
		Id:       &n,
		Comments: &species.Comments.String,
	}}, nil
}

func (s *server) GetByCommonName(ctx context.Context, req *marine.GetByCommonNameRequest) (*marine.GetByCommonNameResponse, error) {
	species, err := s.speciesFetcher.GetByCommonName(req.GetName())
	if err != nil {
		slog.Warn(err.Error())
		return nil, err
	}
	var results []*marine.SpeciesInformation
	for _, specie := range species {
		n := fmt.Sprintf("%d", specie.SpecCode)
		results = append(results, &marine.SpeciesInformation{
			Id:       &n,
			Name:     &n,
			Comments: &specie.Comments.String,
		})
	}
	return &marine.GetByCommonNameResponse{Species: results}, nil
}

func (s *server) CreateRecord(ctx context.Context, req *records.CreateRecordRequest) (*records.CreateRecordResponse, error) {
	id := uuid.New().String()
	req.Record.Id = &id
	err := s.recordWriter.Write(*req.Record)
	if err != nil {
		slog.Warn(err.Error())
		return nil, err
	}
	return &records.CreateRecordResponse{Id: &id}, nil
}

func main() {
	lis, err := net.Listen("tcp", "127.0.0.1:50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()

	db, err := sql.Open("duckdb", "")
	if err != nil {
		log.Fatalf("failed to open DuckDB: %v", err)
	}
	defer db.Close()

	speciesFetcher := species.NewFetcher(db, species.ParquetPaths{
		CommonNames: "bin/comnames_all.parquet",
		Species:     "bin/species.parquet",
	})

	p, err := os.MkdirTemp("", "")
	if err != nil {
		log.Fatalf("failed to create storage: %w", err.Error())
	}
	defer os.RemoveAll(p)
	recordReader := storage.NewFSReader(p)
	recordWriter := storage.NewFSWriter(p)
	server := &server{
		speciesFetcher: speciesFetcher,
		recordReader:   recordReader,
		recordWriter:   recordWriter,
	}

	records.RegisterStorageServer(s, server)
	marine.RegisterCatalogueServer(s, server)
	reflection.Register(s)

	fmt.Println("Server is running on port 50051...")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
