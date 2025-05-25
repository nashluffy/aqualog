package storage

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"

	records "github.com/Nashluffy/aqualog/gen/go/records"
)

type Writer interface {
	Write(records.Record) error
}

type Reader interface {
	Read(id string) (records.Record, error)
}

type fs struct {
	path string
}

func NewFSWriter(path string) Writer {
	return &fs{path: path}
}

func NewFSReader(path string) Reader {
	return &fs{path: path}
}

func (fs *fs) Read(id string) (records.Record, error) {
	filename := fmt.Sprintf("%s/%s.json", fs.path, id)

	var record records.Record
	data, err := os.ReadFile(filename)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return record, fmt.Errorf("file %q does not exist", filename)
		}
		return record, fmt.Errorf("failed to read file: %w", err)
	}

	if err := json.Unmarshal(data, &record); err != nil {
		return record, fmt.Errorf("failed to unmarshal JSON: %w", err)
	}

	return record, nil
}

func (fs *fs) Write(record records.Record) error {
	filename := fmt.Sprintf("%s/%s.json", fs.path, record.GetId())

	jsonData, err := json.MarshalIndent(record, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal data to JSON: %w", err)
	}

	if err := os.WriteFile(filename, jsonData, 0644); err != nil {
		return fmt.Errorf("failed to write file: %w", err)
	}

	return nil
}
