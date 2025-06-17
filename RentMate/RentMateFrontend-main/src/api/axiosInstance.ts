import axios from "axios";

const api = axios.create({
  // baseURL: "http://localhost:5153/api",
  baseURL: "https://localhost:7281/api",
  timeout: 5000,
  headers: {
    "Content-Type": "application/json",
  },
});

export default api;
