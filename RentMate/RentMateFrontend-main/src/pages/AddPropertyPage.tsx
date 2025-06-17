import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { PropertyService } from "../services/PropertyService";
import { useAuth } from "../context/AuthContext";

const AddPropertyPage = () => {
    const navigate = useNavigate();
    const { user } = useAuth(); // ✅ pobieramy zalogowanego użytkownika

    const [form, setForm] = useState({
        title: "",
        location: "",
        price: 0,
        description: "",
        imageUrl: "",
    });

    const [error, setError] = useState("");

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setForm({ ...form, [name]: name === "price" ? parseFloat(value) : value });
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            if (!user) throw new Error("Brak użytkownika");

            await PropertyService.create({
                ...form,
                ownerId: user.id, // ✅ przypisujemy aktualnego użytkownika jako właściciela
            });

            navigate("/my-properties");
        } catch {
            setError("Błąd dodawania ogłoszenia.");
        }
    };

    return (
        <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow max-w-lg mx-auto">
            <h2 className="text-2xl font-bold mb-4">Dodaj nowe mieszkanie</h2>
            {error && <p className="text-red-500 text-sm mb-4">{error}</p>}

            <input name="title" value={form.title} onChange={handleChange} placeholder="Tytuł" required className="w-full border p-2 mb-4 rounded" />
            <textarea name="description" value={form.description} onChange={handleChange} placeholder="Opis" required className="w-full border p-2 mb-4 rounded" />
            <input name="location" value={form.location} onChange={handleChange} placeholder="Lokalizacja" required className="w-full border p-2 mb-4 rounded" />
            <input name="price" type="number" value={form.price} onChange={handleChange} placeholder="Cena (zł)" required className="w-full border p-2 mb-4 rounded" />
            <input name="imageUrl" value={form.imageUrl} onChange={handleChange} placeholder="Link do zdjęcia" className="w-full border p-2 mb-4 rounded" />

            <button type="submit" className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700">
                Dodaj mieszkanie
            </button>
        </form>
    );
};

export default AddPropertyPage;
