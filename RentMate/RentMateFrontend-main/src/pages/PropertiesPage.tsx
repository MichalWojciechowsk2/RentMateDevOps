import { useEffect, useState } from "react";
import {
  getAllProperties,
  searchProperties,
  getCities,
  getDistricts,
} from "../api/property";
import type { Property } from "../types/Property";
import { Link } from "react-router-dom";

interface Filters {
  City?: string;
  District?: string;
  PriceFrom?: number;
  PriceTo?: number;
  Rooms?: number;
}

interface City {
  id: number;
  name: string;
}
interface District {
  id: number;
  name: string;
  enumName: string;
}

const PropertiesPage = () => {
  const [properties, setProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState<Filters>({});
  const [cities, setCities] = useState<City[]>([]);
  const [districts, setDistricts] = useState<District[]>([]);

  useEffect(() => {
    getCities()
      .then(setCities)
      .catch((err) => console.error("Błąd pobierania miast:", err));
  }, []);

  useEffect(() => {
    if (filters.City) {
      getDistricts(filters.City)
        .then(setDistricts)
        .catch((err) => console.error("Błąd pobierania dzielnic:", err));
    } else {
      setDistricts([]);
      setFilters((prev) => ({ ...prev, District: undefined }));
    }
  }, [filters.City]);

  const fetchProperties = async (filters?: Filters) => {
    setLoading(true);
    try {
      let data;
      if (filters && Object.keys(filters).length > 0) {
        data = await searchProperties(filters);
      } else {
        data = await getAllProperties();
      }
      setProperties(data);
    } catch (err) {
      console.error("Błąd ładowania nieruchomości: ", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProperties();
  }, []);

  const handleFilterChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setFilters((prev) => ({
      ...prev,
      [name]:
        value === ""
          ? undefined
          : ["PriceFrom", "PriceTo", "Rooms"].includes(name)
          ? Number(value)
          : value,
    }));
  };
  const handleFilterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const city = cities.find((c) => String(c.id) === filters.City);
    const district = districts.find((d) => d.enumName === filters.District);

    const filtersToSend = {
      ...filters,
      City: city?.name,
      District: district?.enumName,
    };

    fetchProperties(filtersToSend);
  };
  const handleReset = () => {
    setFilters({});
    setDistricts([]);
    fetchProperties();
  };

  if (loading) return <p className="p-6">Ładowanie ofert...</p>;

  return (
    <div className="p-6">
      <form
        onSubmit={handleFilterSubmit}
        className="mb-15 flex flex-wrap gap-4 items-end"
      >
        <div>
          <label className="block mb-1">Miasto:</label>
          <select
            name="City"
            value={filters.City ?? ""}
            onChange={handleFilterChange}
            className="border rounded px-2 py-1 w-75"
          >
            <option value="" className="text-black">
              -- Wybierz miasto --
            </option>
            {cities.map((c) => (
              <option key={c.id} value={String(c.id)} className="text-black">
                {c.name}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block mb-1 ">Osiedle:</label>
          <select
            name="District"
            value={filters.District ?? ""}
            onChange={handleFilterChange}
            disabled={!filters.City}
            className="border rounded px-2 py-1 w-75"
          >
            <option value="" className="text-black">
              -- Wybierz osiedle --
            </option>
            {districts.map((d) => (
              <option key={d.id} value={d.enumName} className="text-black">
                {d.name}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block mb-1">Min. cena (zł):</label>
          <input
            type="number"
            name="PriceFrom"
            value={filters.PriceFrom || ""}
            onChange={handleFilterChange}
            className="border rounded px-2 py-1"
          />
        </div>
        <div>
          <label className="block mb-1">Max. cena (zł):</label>
          <input
            type="number"
            name="PriceTo"
            value={filters.PriceTo || ""}
            onChange={handleFilterChange}
            className="border rounded px-2 py-1"
          />
        </div>
        <div>
          <label className="block mb-1">Liczba pokoi:</label>
          <input
            type="number"
            name="Rooms"
            value={filters.Rooms || ""}
            onChange={handleFilterChange}
            className="border rounded px-2 py-1"
          />
        </div>

        <div className="flex gap-2">
          <button
            type="submit"
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition"
          >
            Filtruj
          </button>
          <button
            type="button"
            onClick={handleReset}
            className="bg-gray-400 text-white px-4 py-2 rounded hover:bg-gray-500 transition"
          >
            Resetuj
          </button>
        </div>
      </form>

      <ul>
        {properties.map((property) => (
          <li key={property.id}>
            <Link to={`/property/${property.id}`}>
              <div className="flex flex-col md:flex-row bg-white shadow-md rounded-2xl overflow-hidden mb-4 hover:shadow-lg transition-shadow duration-300">
                {/* Placeholder na zdjęcie */}
                <div className="w-full md:w-48 h-48 bg-gray-200 flex items-center justify-center text-gray-500">
                  Zdj
                </div>

                {/* Szczegóły */}
                <div className="flex flex-col justify-between p-4 w-full">
                  <h2 className="text-xl font-semibold text-gray-800 mb-2">
                    {property.title}
                  </h2>
                  <p className="text-gray-600 mb-1 line-clamp-2">
                    {property.description}
                  </p>
                  <p className="text-sm text-gray-500">📍 {property.address}</p>
                  <div className="flex justify-between mt-2 text-sm text-gray-700">
                    <span>🛏️ {property.roomCount} pokoi</span>
                    <span>💰 {property.basePrice} zł/mc</span>
                  </div>
                </div>
              </div>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default PropertiesPage;
