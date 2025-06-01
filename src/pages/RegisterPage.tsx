import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { mockRegister } from "../services/AuthService";

type RegisterForm = {
    email: string;
    password: string;
    username: string;
    role: "Tenant" | "Owner" | "Admin";
};

const RegisterPage = () => {
    const navigate = useNavigate();

    const [form, setForm] = useState<RegisterForm>({
        email: "",
        password: "",
        username: "",
        role: "Tenant",
    });

    const [error, setError] = useState("");

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
        const { name, value } = e.target;
        setForm((prev) => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await mockRegister(form);
            navigate("/login");
        } catch (err) {
            if (err instanceof Error) {
                setError(err.message);
            } else {
                setError("Błąd rejestracji.");
            }
        }
    };

    return (
        <form onSubmit={handleSubmit} className="max-w-md mx-auto p-6 bg-white rounded shadow">
            <h2 className="text-xl font-bold mb-4">Rejestracja</h2>
            {error && <p className="text-red-500 mb-2">{error}</p>}

            <input
                name="username"
                value={form.username}
                onChange={handleChange}
                placeholder="Nazwa użytkownika"
                required
                className="w-full border p-2 mb-4"
            />
            <input
                name="email"
                type="email"
                value={form.email}
                onChange={handleChange}
                placeholder="Email"
                required
                className="w-full border p-2 mb-4"
            />
            <input
                name="password"
                type="password"
                value={form.password}
                onChange={handleChange}
                placeholder="Hasło"
                required
                className="w-full border p-2 mb-4"
            />

            <select
                name="role"
                value={form.role}
                onChange={handleChange}
                className="w-full border p-2 mb-4"
            >
                <option value="Tenant">Najemca</option>
                <option value="Owner">Właściciel</option>
                <option value="Admin">Admin</option>
            </select>

            <button type="submit" className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700">
                Zarejestruj się
            </button>
        </form>
    );
};

export default RegisterPage;
