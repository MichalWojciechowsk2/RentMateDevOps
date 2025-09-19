import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const LoginPage = () => {
    const navigate = useNavigate();
    const { login } = useAuth();

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            await login(email, password);
            navigate("/dashboard");
        } catch {
            setError("Nieprawidłowy login lub hasło.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex justify-center items-center h-[80vh]">
            <form onSubmit={handleSubmit} className="bg-white p-8 rounded shadow-md w-full max-w-md">
                <h2 className="text-2xl font-bold mb-6 text-center">Zaloguj się</h2>
                {error && <p className="text-red-500 text-sm mb-4">{error}</p>}
                <input
                    type="email"
                    placeholder="Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full mb-4 px-4 py-2 border rounded"
                    required
                />
                <input
                    type="password"
                    placeholder="Hasło"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full mb-4 px-4 py-2 border rounded"
                    required
                />
                <button
                    type="submit"
                    disabled={loading}
                    className={`w-full py-2 rounded text-white ${loading ? "bg-gray-500" : "bg-blue-600 hover:bg-blue-700"}`}
                >
                    {loading ? "Logowanie..." : "Zaloguj się"}
                </button>
            </form>
        </div>
    );
};

export default LoginPage;
