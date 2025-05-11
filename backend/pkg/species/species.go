package species

import (
	"database/sql"
	"fmt"
	"log"
)

type Species struct {
	SpecCode int
	Comments string
}

type Fetcher interface {
	GetByID(id int) (*Species, error)
}

type fetcher struct {
	dbConn *sql.DB
	host   string
}

func NewFetcher(dbConn *sql.DB, host string) Fetcher {
	return &fetcher{
		dbConn: dbConn,
		host:   host,
	}
}

func (s *fetcher) GetByID(id int) (*Species, error) {
	// Use DuckDB SQL to query the remote Parquet file
	query := fmt.Sprintf(`SELECT SpecCode,Comments FROM read_parquet('%s') WHERE SpecCode == '%d' LIMIT 10 `, s.host, id)

	rows, err := s.dbConn.Query(query)
	if err != nil {
		log.Fatalf("Failed to query parquet file: %v", err)
	}
	defer rows.Close()

	var results []Species
	for rows.Next() {
		var s Species
		if err := rows.Scan(&s.SpecCode, &s.Comments); err != nil {
			log.Fatalf("Failed to scan row: %v", err)
		}
		results = append(results, s)
	}

	if len(results) == 0 {
		return nil, fmt.Errorf("no specifes found with id: %d", id)
	}

	return &results[0], nil
}
