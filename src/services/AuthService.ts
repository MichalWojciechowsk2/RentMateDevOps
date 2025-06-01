import axios from "axios";
import type { User } from "../types/User";

const API_URL = "https://localhost:5001/api"; // docelowy backend

// -----------------------------
// BACKEND - prawdziwy login/register (axios)
// -----------------------------
export const AuthService = {
    login: async (email: string, password: string) => {
        const response = await axios.post(`${API_URL}/auth/login`, { email, password });
        return response.data;
    },

    register: async (email: string, password: string) => {
        const response = await axios.post(`${API_URL}/auth/register`, { email, password });
        return response.data;
    },
};

// -----------------------------
// MOCK - z użyciem localStorage
// -----------------------------
const USERS_KEY = "mock_users";
let nextUserId = 4;

const getMockUsers = (): User[] => {
    const json = localStorage.getItem(USERS_KEY);
    return json ? JSON.parse(json) : [];
};

const saveMockUsers = (users: User[]) => {
    localStorage.setItem(USERS_KEY, JSON.stringify(users));
};

export const mockLogin = async (email: string, password: string) => {
    const users = getMockUsers();
    const user = users.find((u) => u.email === email && u.password === password);
    if (!user) throw new Error("Invalid credentials");

    return {
        user,
        token: "mock-jwt-token-123",
    };
};

export const mockRegister = async ({
    email,
    password,
    username,
    role,
}: {
    email: string;
    password: string;
    username: string;
    role: "Admin" | "Owner" | "Tenant";
}) => {
    const users = getMockUsers();

    const exists = users.find((u) => u.email === email);
    if (exists) throw new Error("Użytkownik już istnieje");

    const newUser: User = {
        id: nextUserId++,
        email,
        password,
        username,
        role,
    };

    users.push(newUser);
    saveMockUsers(users);
    return true;
};

export const logout = () => {
    localStorage.removeItem("user");
    localStorage.removeItem("token");
};

export const getCurrentUser = (): User | null => {
    const user = localStorage.getItem("user");
    return user ? JSON.parse(user) : null;
};
