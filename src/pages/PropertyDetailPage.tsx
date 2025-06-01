import { useParams } from "react-router-dom";
import { useEffect, useState } from "react";
import { PropertyService } from "../services/PropertyService";
import type { Property } from "../types/Property";

const PropertyDetailPage = () => {
    const { id } = useParams();
    const [property, setProperty] = useState<Property | null>(null);

    useEffect(() => {
        if (id) {
            PropertyService.getById(Number(id)).then((property) => {
                setProperty(property ?? null);
            });
        }
    }, [id]);

    if (!property) return <p className="p-6">Ładowanie danych mieszkania...</p>;

    return (
        <div className="p-6 max-w-3xl mx-auto bg-white shadow rounded">
            {property.imageUrl && (
                <img src={property.imageUrl} alt="Zdjęcie mieszkania" className="w-full h-64 object-cover mb-4 rounded" />
            )}
            <h1 className="text-2xl font-bold mb-2">{property.title}</h1>
            <p className="text-gray-600 mb-2">{property.location}</p>
            <p className="mb-2">{property.description}</p>
            <p className="font-bold">{property.price} zł / miesiąc</p>
        </div>
    );
};

export default PropertyDetailPage;
