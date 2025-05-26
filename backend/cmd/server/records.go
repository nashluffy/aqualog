package main

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/Nashluffy/aqualog/gen/records"
	"github.com/google/uuid"
)

func (s *server) ReadRecord(ctx context.Context, req *records.ReadRecordRequest) (*records.ReadRecordResponse, error) {
	r, err := s.recordReader.Read(req.GetId())
	if err != nil {
		slog.Warn(err.Error())
		return nil, fmt.Errorf("no record found: %w", err.Error())
	}
	return &records.ReadRecordResponse{Record: &r}, nil
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

func (s *server) ListRecords(ctx context.Context, req *records.ListRecordsRequest) (*records.ListRecordsResponse, error) {
	r, err := s.recordReader.List()
	if err != nil {
		slog.Warn(err.Error())
		return nil, err
	}
	return &records.ListRecordsResponse{Records: r}, nil
}
