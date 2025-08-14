package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"srecha-invoice-api/config"
	"srecha-invoice-api/handlers"
	"srecha-invoice-api/middleware"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize database connection
	db, err := config.InitDB()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	// Set Gin mode
	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Create Gin router
	r := gin.New()

	// Add middleware
	r.Use(gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
			param.ClientIP,
			param.TimeStamp.Format(time.RFC1123),
			param.Method,
			param.Path,
			param.Request.Proto,
			param.StatusCode,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	}))
	r.Use(gin.Recovery())

	// CORS configuration
	corsConfig := cors.Config{
		AllowOrigins:     []string{getEnv("FRONTEND_URL", "http://localhost:8080")},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Length", "Content-Type", "Authorization"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}
	r.Use(cors.New(corsConfig))

	// Rate limiting middleware
	r.Use(middleware.RateLimit())

	// Health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":      "OK",
			"timestamp":   time.Now().Format(time.RFC3339),
			"environment": getEnv("GIN_MODE", "debug"),
		})
	})

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(db)
	clientHandler := handlers.NewClientHandler(db)
	invoiceHandler := handlers.NewInvoiceHandler(db)
	productHandler := handlers.NewProductHandler(db)
	deliveryHandler := handlers.NewDeliveryHandler(db)
	exportHandler := handlers.NewExportHandler(db)
	logHandler := handlers.NewLogHandler(db)

	// API routes
	api := r.Group("/api")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.GET("/profile", middleware.AuthRequired(), authHandler.GetProfile)
			auth.PUT("/profile", middleware.AuthRequired(), authHandler.UpdateProfile)
			auth.PUT("/change-password", middleware.AuthRequired(), authHandler.ChangePassword)
			auth.POST("/logout", middleware.AuthRequired(), authHandler.Logout)

			// Admin only user management
			auth.GET("/users", middleware.AuthRequired(), middleware.AdminRequired(), authHandler.GetUsers)
			auth.POST("/users", middleware.AuthRequired(), middleware.AdminRequired(), authHandler.CreateUser)
			auth.PUT("/users/:id/permissions", middleware.AuthRequired(), middleware.AdminRequired(), authHandler.UpdateUserPermissions)
			auth.DELETE("/users/:id", middleware.AuthRequired(), middleware.AdminRequired(), authHandler.DeleteUser)
			auth.PUT("/users/:id/toggle-status", middleware.AuthRequired(), middleware.AdminRequired(), authHandler.ToggleUserStatus)
		}

		// Client routes
		clients := api.Group("/clients")
		clients.Use(middleware.AuthRequired())
		{
			clients.GET("", clientHandler.GetClients)
			clients.GET("/:id", clientHandler.GetClient)
			clients.POST("", clientHandler.CreateClient)
			clients.PUT("/:id", clientHandler.UpdateClient)
			clients.DELETE("/:id", clientHandler.DeleteClient)
			clients.GET("/:id/invoices", clientHandler.GetClientInvoices)
			clients.GET("/:id/deliveries", clientHandler.GetClientDeliveries)
			clients.GET("/:id/statistics", clientHandler.GetClientStatistics)
		}

		// Product routes
		products := api.Group("/products")
		products.Use(middleware.AuthRequired())
		{
			products.GET("", productHandler.GetProducts)
			products.GET("/:id", productHandler.GetProduct)
			products.POST("", productHandler.CreateProduct)
			products.PUT("/:id", productHandler.UpdateProduct)
			products.DELETE("/:id", productHandler.DeleteProduct)
		}

		// Product group routes
		productGroups := api.Group("/product-groups")
		productGroups.Use(middleware.AuthRequired())
		{
			productGroups.GET("", productHandler.GetProductGroups)
			productGroups.GET("/:id", productHandler.GetProductGroup)
			productGroups.POST("", productHandler.CreateProductGroup)
			productGroups.PUT("/:id", productHandler.UpdateProductGroup)
			productGroups.DELETE("/:id", productHandler.DeleteProductGroup)
			productGroups.POST("/:id/products", productHandler.AddProductToGroup)
			productGroups.DELETE("/:id/products/:productId", productHandler.RemoveProductFromGroup)
		}

		// Invoice routes
		invoices := api.Group("/invoices")
		invoices.Use(middleware.AuthRequired())
		{
			invoices.GET("", invoiceHandler.GetInvoices)
			invoices.GET("/:id", invoiceHandler.GetInvoice)
			invoices.POST("", invoiceHandler.CreateInvoice)
			invoices.PATCH("/:id/status", invoiceHandler.UpdateInvoiceStatus)
			invoices.PATCH("/:id/tracking", invoiceHandler.UpdateInvoiceTracking)
			invoices.DELETE("/:id", invoiceHandler.DeleteInvoice)
		}

		// Delivery routes
		deliveries := api.Group("/deliveries")
		deliveries.Use(middleware.AuthRequired())
		{
			deliveries.GET("", deliveryHandler.GetDeliveries)
			deliveries.GET("/:id", deliveryHandler.GetDelivery)
			deliveries.POST("", deliveryHandler.CreateDelivery)
			deliveries.PUT("/:id", deliveryHandler.UpdateDelivery)
			deliveries.DELETE("/:id", deliveryHandler.DeleteDelivery)
		}

		// Export routes
		exports := api.Group("/export")
		exports.Use(middleware.AuthRequired())
		{
			exports.GET("/invoices", exportHandler.ExportInvoices)
			exports.GET("/clients", exportHandler.ExportClients)
		}

		// Log routes
		logs := api.Group("/logs")
		logs.Use(middleware.AuthRequired())
		{
			logs.GET("", logHandler.GetLogs)
		}
	}

	// Static files for uploads
	r.Static("/uploads", "./uploads")

	// 404 handler
	r.NoRoute(func(c *gin.Context) {
		c.JSON(http.StatusNotFound, gin.H{"error": "Route not found"})
	})

	// Start server
	port := getEnv("PORT", "3000")
	log.Printf("🚀 Srecha Invoice Backend running on port %s", port)
	log.Printf("📊 Environment: %s", getEnv("GIN_MODE", "debug"))
	log.Printf("🔗 Health check: http://localhost:%s/health", port)

	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
