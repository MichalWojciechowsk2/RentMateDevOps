import api from "./axiosInstance";
import type { Property } from "../types/Property";

export const getAllProperties = async (): Promise<Property[]> => {
  const response = await api.get<Property[]>("/Property");
  return response.data;
};

export const searchProperties = async (filters: any): Promise<Property[]> => {
  const response = await api.get<Property[]>("/Property/search", {
    params: filters,
  });
  console.log(filters);
  return response.data;
};

export const getCities = async (): Promise<{ id: number; name: string }[]> => {
  const response = await api.get<{ id: number; name: string }[]>(
    "/Property/cities"
  );
  return response.data;
};

export const getDistricts = async (
  cityId: string
): Promise<{ id: number; name: string; enumName: string }[]> => {
  const response = await api.get<
    { id: number; name: string; enumName: string }[]
  >(`/Property/districts/${cityId}`);
  console.log(response.data);
  return response.data;
};
