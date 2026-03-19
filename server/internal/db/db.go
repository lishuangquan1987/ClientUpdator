package db

import (
	"context"
	"database/sql"
	"log"

	"clientupdator/server/ent"

	sqldialect "entgo.io/ent/dialect/sql"

	_ "modernc.org/sqlite"
)

var Client *ent.Client

func GetTxClient() *ent.Client {
	return Client.Tx()
}

func InitDB() {
	//初始化数据库
	var err error
	db, err := sql.Open("sqlite", "./configs/clientupdator.db?_fk=1")
	if err != nil {
		log.Fatalf("failed opening connection to sqlite: %v", err)
	}
	// Enable foreign keys
	_, err = db.Exec("PRAGMA foreign_keys = ON")
	if err != nil {
		log.Fatalf("failed enabling foreign keys: %v", err)
	}
	// Create a custom ent driver with sqlite3 dialect
	driver := sqldialect.OpenDB("sqlite3", db)
	Client = ent.NewClient(ent.Driver(driver))
	defer Client.Close()
	// Run the auto migration tool.
	if err := Client.Schema.Create(context.Background()); err != nil {
		log.Fatalf("failed creating schema resources: %v", err)
	}
}
