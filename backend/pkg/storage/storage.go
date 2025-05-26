package storage

import (
	"encoding/json"
	"errors"
	"fmt"
	iofs "io/fs"
	"os"
	"path/filepath"

	"github.com/Nashluffy/aqualog/gen/records"
)

type Writer interface {
	Write(records.Record) error
}

type Reader interface {
	List() ([]*records.Record, error)
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

func (fs *fs) List() ([]*records.Record, error) {
	var records []*records.Record
	err := filepath.WalkDir(fs.path, func(path string, d iofs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		r, err := readFromFile(path)
		if err != nil {
			return err
		}
		records = append(records, &r)
		return nil
	})

	if err != nil {
		return nil, fmt.Errorf("error walking the path %s: %w", fs.path, err)
	}
	return records, nil
}

func (fs *fs) Read(id string) (records.Record, error) {
	filename := fmt.Sprintf("%s/%s.json", fs.path, id)
	return readFromFile(filename)
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

func readFromFile(filename string) (records.Record, error) {
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
