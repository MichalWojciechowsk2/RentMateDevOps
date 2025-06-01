import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { PropertyService } from "../services/PropertyService";
import type { Property } from "../types/Property";

const EditPropertyPage = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [form, setForm] = useState<Omit<Property, "id"> | null>(null);

    useEffect(() => {
        if (id) {
            PropertyService.getById(Number(id)).then((p) => {
                if (p) {
                    setForm({
                        title: p.title,
                        location: p.location,
                        price: p.price,
                        description: p.description,
                        imageUrl: p.imageUrl,
                        ownerId: p.ownerId
                    });
                }
            });
        }
    }, [id]);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setForm((prev) => prev ? { ...prev, [name]: name === "price" ? parseFloat(value) : value } : null);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!form || !id) return;
        await PropertyService.update(Number(id), form);
        navigate("/my-properties");
    };

    if (!form) return <p className="p-6">Ładowanie formularza...</p>;

    return (
        <form onSubmit={handleSubmit} className="max-w-xl mx-auto p-6 bg-white rounded shadow">
            <h2 className="text-2xl font-bold mb-4">Edytuj ofertę</h2>
            <input name="title" value={form.title} onChange={handleChange} className="w-full border p-2 mb-4" />
            <textarea name="description" value={form.description} onChange={handleChange} className="w-full border p-2 mb-4" />
            <input name="location" value={form.location} onChange={handleChange} className="w-full border p-2 mb-4" />
            <input type="number" name="price" value={form.price} onChange={handleChange} className="w-full border p-2 mb-4" />
            <input name="imageUrl" value={form.imageUrl} onChange={handleChange} className="w-full border p-2 mb-4" placeholder="URL do zdjęcia" />
            <button type="submit" className="bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700">Zapisz</button>
        </form>
    );
};

export default EditPropertyPage;
