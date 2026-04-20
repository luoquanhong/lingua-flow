package model

import "time"

type Word struct {
	ID         string    `json:"id"`
	UserID     string    `json:"user_id"`
	Term       string    `json:"term"`
	Definition string    `json:"definition"`
	Phonetic   string    `json:"phonetic"`
	Tags       []string  `json:"tags"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type AddWordRequest struct {
	Term       string   `json:"term" binding:"required"`
	Definition string   `json:"definition" binding:"required"`
	Phonetic   string   `json:"phonetic"`
	Tags       []string `json:"tags"`
}

type UpdateWordRequest struct {
	Term       string   `json:"term"`
	Definition string   `json:"definition"`
	Phonetic   string   `json:"phonetic"`
	Tags       []string `json:"tags"`
}
