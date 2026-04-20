package db

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

var pool *pgxpool.Pool

func Connect(databaseURL string) error {
	var err error
	pool, err = pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		return err
	}
	return pool.Ping(context.Background())
}

func Close() {
	if pool != nil {
		pool.Close()
	}
}

func Pool() *pgxpool.Pool {
	return pool
}
