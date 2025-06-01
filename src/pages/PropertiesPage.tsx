import { useEffect, useState } from "react";
import { PropertyService } from "../services/PropertyService";
import type { Property } from "../types/Property";

const PropertiesPage = () => {
    const [properties, setProperties] = useState<Property[]>([]);
    const [filtered, setFiltered] = useState<Property[]>([]);
    const [loading, setLoading] = useState(true);

    // 🔍 filtry
    const [locationFilter, setLocationFilter] = useState("");
    const [maxPrice, setMaxPrice] = useState<number | undefined>(undefined);
    const [sortOrder, setSortOrder] = useState<"asc" | "desc">("asc");

    useEffect(() => {
        PropertyService.getAll()
            .then((data) => {
                setProperties(data);
                setFiltered(data);
            })
            .catch(() => alert("Błąd pobierania danych"))
            .finally(() => setLoading(false));
    }, []);

    useEffect(() => {
        let results = [...properties];

        if (locationFilter.trim() !== "") {
            results = results.filter((p) =>
                p.location.toLowerCase().includes(locationFilter.toLowerCase())
            );
        }

        if (maxPrice !== undefined && !isNaN(maxPrice)) {
            results = results.filter((p) => p.price <= maxPrice);
        }

        results.sort((a, b) =>
            sortOrder === "asc" ? a.price - b.price : b.price - a.price
        );

        setFiltered(results);
    }, [locationFilter, maxPrice, sortOrder, properties]);

    if (loading) return <p className="p-6">Ładowanie ofert...</p>;

    return (
        <div className="p-6">
            <h1 className="text-2xl font-bold mb-4">Dostępne mieszkania</h1>

            {/* 🔧 Filtry i sortowanie */}
            <div className="flex flex-col md:flex-row gap-4 mb-6">
                <input
                    type="text"
                    placeholder="Szukaj lokalizacji..."
                    className="border p-2 rounded w-full md:w-1/3"
                    value={locationFilter}
                    onChange={(e) => setLocationFilter(e.target.value)}
                />

                <input
                    type="number"
                    placeholder="Cena maksymalna"
                    className="border p-2 rounded w-full md:w-1/3"
                    value={maxPrice ?? ""}
                    onChange={(e) => setMaxPrice(e.target.value ? parseFloat(e.target.value) : undefined)}
                />

                <select
                    className="border p-2 rounded w-full md:w-1/3"
                    value={sortOrder}
                    onChange={(e) => setSortOrder(e.target.value as "asc" | "desc")}
                >
                    <option value="asc">Cena rosnąco</option>
                    <option value="desc">Cena malejąco</option>
                </select>
            </div>

            {/* 📦 Lista mieszkań */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filtered.map((property) => (
                    <div key={property.id} className="border rounded p-4 shadow-sm bg-white">
                        <h2 className="text-xl font-semibold">{property.title}</h2>
                        <p className="text-gray-600 mb-2">{property.location}</p>
                        <p className="mb-2">{property.description}</p>
                        <p className="font-bold">{property.price} zł / miesiąc</p>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default PropertiesPage;
