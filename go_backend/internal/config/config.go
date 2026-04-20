package config

import "os"

type Config struct {
	Port        string
	DatabaseURL string
	JWTSecret   string
	DeepSeekKey string
	DeepSeekURL string
}

func Load() *Config {
	return &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: getEnv("DATABASE_URL", ""),
		JWTSecret:   getEnv("JWT_SECRET", ""),
		DeepSeekKey: getEnv("DEEPSEEK_API_KEY", ""),
		DeepSeekURL: getEnv("DEEPSEEK_BASE_URL", "https://api.deepseek.com"),
	}
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}
