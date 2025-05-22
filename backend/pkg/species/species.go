package species

import (
	"database/sql"
	"fmt"
	"log"
	"strings"
)

type Species struct {
	SpecCode int
	Comments sql.NullString
}

type speciesFromCommonName struct {
	CommonName string
	SpeciesID  int
}

type ParquetPaths struct {
	Species     string
	CommonNames string
}

type Fetcher interface {
	GetByIDs(id []int) ([]Species, error)
	GetByCommonName(cn string) ([]Species, error)
}

type fetcher struct {
	dbConn       *sql.DB
	parquetPaths ParquetPaths
}

func NewFetcher(dbConn *sql.DB, parquetPaths ParquetPaths) Fetcher {
	return &fetcher{
		dbConn:       dbConn,
		parquetPaths: parquetPaths,
	}
}

func (s *fetcher) GetByCommonName(cn string) ([]Species, error) {
	query := fmt.Sprintf(`SELECT CommonName, SpeciesID FROM read_parquet('%s') WHERE CommonName ILIKE ? `, s.parquetPaths.CommonNames)
	condition := "%" + cn + "%"
	rows, err := s.dbConn.Query(query, condition)
	if err != nil {
		log.Fatalf("Failed to query parquet file: %v", err)
	}
	defer rows.Close()

	var speciesIDByCN []int
	for rows.Next() {
		var s speciesFromCommonName
		if err := rows.Scan(&s.CommonName, &s.SpeciesID); err != nil {
			log.Fatalf("Failed to scan row: %v", err)
		}
		speciesIDByCN = append(speciesIDByCN, s.SpeciesID)
	}

	return s.GetByIDs(speciesIDByCN)
}

func (s *fetcher) GetByIDs(ids []int) ([]Species, error) {
	if len(ids) == 0 {
		return nil, nil
	}
	inClause, args := buildInClause(ids)
	query := fmt.Sprintf(`SELECT SpecCode,Comments FROM read_parquet('%s') WHERE SpecCode IN %s`, s.parquetPaths.Species, inClause)

	rows, err := s.dbConn.Query(query, args...)
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

	return results, nil
}

func buildInClause(ints []int) (string, []interface{}) {
	placeholders := make([]string, len(ints))
	args := make([]interface{}, len(ints))
	for i, val := range ints {
		placeholders[i] = "?"
		args[i] = val
	}
	clause := fmt.Sprintf("(%s)", strings.Join(placeholders, ", "))
	return clause, args
}
