import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import compression from "compression";
import sequelize from "../db/connection.js";

// Import associations to establish model relationships
import "../models/associations.js";

import apiRoutes from "../routes/index.js";

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT) || 8080;

app.use(
  cors({
    origin: "http://localhost:3000",
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE"],
  })
);

app.use(compression());

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

app.use("/api", apiRoutes);

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
  });
});

app.get("/", (req, res) => {
  res.json({
    message: "RatoPos API Server",
    version: "1.0.0",
    documentation: "/api/docs",
    health: "/health",
  });
});

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: "Route not found",
    path: req.originalUrl,
  });
});

app.use(
  (
    err: any,
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ) => {
    console.error("Global error handler:", err);

    const isDev = process.env.NODE_ENV === "development";

    res.status(err.status || 500).json({
      success: false,
      error: isDev ? err.message : "Internal server error",
      ...(isDev && { stack: err.stack }),
    });
  }
);

const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log("✅ Database connection established successfully");

    if (process.env.NODE_ENV === "development") {
      await sequelize.sync();
      console.log("✅ Database synchronized");
    }

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 Server is running on http://localhost:${PORT}`);
      console.log(`🔒 Environment: ${process.env.NODE_ENV || "development"}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error("❌ Unable to start server:", error);
    process.exit(1);
  }
};

process.on("SIGTERM", async () => {
  console.log("🔄 SIGTERM received, shutting down gracefully...");
  await sequelize.close();
  process.exit(0);
});

process.on("SIGINT", async () => {
  console.log("🔄 SIGINT received, shutting down gracefully...");
  await sequelize.close();
  process.exit(0);
});

startServer();
