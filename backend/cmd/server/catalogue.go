package main

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/Nashluffy/aqualog/gen/marine"
)

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
