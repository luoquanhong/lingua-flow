package main

import (
	"log"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	"github.com/luoquanhong/lingua-flow/backend/internal/config"
	"github.com/luoquanhong/lingua-flow/backend/internal/handler"
	"github.com/luoquanhong/lingua-flow/backend/internal/middleware"
	"github.com/luoquanhong/lingua-flow/backend/pkg/db"
)

func main() {
	// 1. 加载 .env 配置
	if err := godotenv.Load(); err != nil {
		log.Println("[warn] .env file not found, using environment variables")
	}

	cfg := config.Load()

	// 2. 连接 PostgreSQL（通过 PGX）
	if cfg.DatabaseURL != "" {
		if err := db.Connect(cfg.DatabaseURL); err != nil {
			log.Fatalf("failed to connect to database: %v", err)
		}
		defer db.Close()
		log.Println("[info] PostgreSQL connected")
	}

	// 3. 初始化 Gin 路由
	r := gin.Default()

	// 路由预留 — Sprint 1 实现时替换占位符
	v1 := r.Group("/api/v1")
	{
		auth := v1.Group("/auth")
		{
			auth.POST("/register", handler.Register)
			auth.POST("/login", handler.Login)
		}

		words := v1.Group("/words")
		words.Use(middleware.AuthRequired())
		{
			words.GET("", handler.ListWords)
			words.POST("", handler.AddWord)
			words.GET("/:id", handler.GetWord)
			words.PUT("/:id", handler.UpdateWord)
			words.DELETE("/:id", handler.DeleteWord)
		}

		scenes := v1.Group("/scenes")
		scenes.Use(middleware.AuthRequired())
		{
			scenes.POST("/generate", handler.GenerateScene)
			scenes.GET("", handler.ListScenes)
			scenes.GET("/:id", handler.GetScene)
		}
	}

	// 4. 启动 Gin server
	log.Printf("[info] server starting on :%s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}
