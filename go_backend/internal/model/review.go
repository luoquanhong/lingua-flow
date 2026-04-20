package model

import "time"

type Review struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	WordID       string    `json:"word_id"`
	SceneID      string    `json:"scene_id"`
	Score        int       `json:"score"`
	NextReviewAt time.Time `json:"next_review_at"`
	CreatedAt    time.Time `json:"created_at"`
}

type Scene struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	WordID    string    `json:"word_id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
}

type GenerateSceneRequest struct {
	WordID string `json:"word_id" binding:"required"`
}
