import { useEffect, useState } from "react";
import { useAuth } from "../context/AuthContext";
import { PropertyService } from "../services/PropertyService";
import type { Property } from "../types/Property";

const MyPropertiesPage = () => {
    const { user } = useAuth();
    const [properties, setProperties] = useState<Property[]>([]);

    useEffect(() => {
        if (user) {
            PropertyService.getByOwner(user.id).then(setProperties);
        }
    }, [user]);

    const handleDelete = async (id: number) => {
        await PropertyService.delete(id);
        const updated = await PropertyService.getByOwner(user!.id);
        setProperties(updated);
    };

    return (
        <div className="p-6">
            <h1 className="text-2xl font-bold mb-4">Moje mieszkania</h1>
            {properties.map((p) => (
                <div key={p.id} className="border rounded p-4 mb-4 bg-white shadow">
                    <h2 className="text-xl font-semibold">{p.title}</h2>
                    <p>{p.location}</p>
                    <p>{p.description}</p>
                    <p className="font-bold">{p.price} zł / miesiąc</p>
                    <button
                        onClick={() => handleDelete(p.id)}
                        className="mt-2 text-sm bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
                    >
                        Usuń
                    </button>
                </div>
            ))}
        </div>
    );
};

export default MyPropertiesPage;
