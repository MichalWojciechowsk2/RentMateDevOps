import type { Property } from "../types/Property";

const STORAGE_KEY = "mock_properties";

const getStoredProperties = (): Property[] => {
    const json = localStorage.getItem(STORAGE_KEY);
    return json ? JSON.parse(json) : [];
};

const saveProperties = (properties: Property[]) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(properties));
};

let nextId = 1;

export const PropertyService = {
    getAll: async (): Promise<Property[]> => {
        return getStoredProperties();
    },

    create: async (property: Omit<Property, "id">): Promise<boolean> => {
        const current = getStoredProperties();
        const newProperty = { ...property, id: nextId++ };
        saveProperties([...current, newProperty]);
        return true;
    },

    delete: async (id: number): Promise<void> => {
        const current = getStoredProperties();
        saveProperties(current.filter((p) => p.id !== id));
    },

    getByOwner: async (ownerId: number): Promise<Property[]> => {
        return getStoredProperties().filter((p) => p.ownerId === ownerId);
    },

    getById: async (id: number): Promise<Property | undefined> => {
        return getStoredProperties().find((p) => p.id === id);
    },

    update: async (id: number, updatedData: Omit<Property, "id">): Promise<void> => {
        const all = getStoredProperties();
        const idx = all.findIndex((p) => p.id === id);
        if (idx !== -1) {
            all[idx] = { ...all[idx], ...updatedData };
            saveProperties(all);
        }
    },
};
