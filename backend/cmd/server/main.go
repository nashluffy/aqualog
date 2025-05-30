package main

import (
	"log"
	"log/slog"
	"net"
	"os"

	"database/sql"

	_ "github.com/marcboeker/go-duckdb"

	"github.com/Nashluffy/aqualog/backend/pkg/species"
	"github.com/Nashluffy/aqualog/gen/marine"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct {
	marine.UnimplementedCatalogueServer
	speciesFetcher species.Fetcher
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
	slog.Info("persisting records", "path", p)
	defer os.RemoveAll(p)
	server := &server{
		speciesFetcher: speciesFetcher,
	}
	marine.RegisterCatalogueServer(s, server)
	reflection.Register(s)

	slog.Info("server is running", "addr", lis.Addr().String())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
