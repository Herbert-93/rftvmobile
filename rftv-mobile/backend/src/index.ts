import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";

import { notFound, errorHandler } from "./middleware/errorHandler";

import authRoutes from "./routes/auth";
import setupRoutes from "./routes/setup";
import channelsRoutes from "./routes/channels";
import programsRoutes from "./routes/programs";
import radioRoutes from "./routes/radio";
import donationsRoutes from "./routes/donations";
import usersRoutes from "./routes/users";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;
const allowedOrigins = (process.env.CORS_ORIGINS || "").split(",").map((s) => s.trim()).filter(Boolean);

app.use(helmet());
app.use(express.json());
app.use(morgan("dev"));
app.use(
  cors({
    origin: allowedOrigins.length ? allowedOrigins : true,
    credentials: true,
  })
);

app.get("/", (_req, res) => {
  res.json({ name: "RF TV Mobile API", status: "ok" });
});

app.get("/health", (_req, res) => res.json({ status: "ok", time: new Date().toISOString() }));

app.use("/auth", authRoutes);
app.use("/setup", setupRoutes);
app.use("/channels", channelsRoutes);
app.use("/programs", programsRoutes);
app.use("/radio", radioRoutes);
app.use("/donations", donationsRoutes);
app.use("/users", usersRoutes);

app.use(notFound);
app.use(errorHandler);

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`RF TV backend listening on port ${PORT}`);
});
