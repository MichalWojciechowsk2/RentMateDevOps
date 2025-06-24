import axios, { AxiosError } from "axios";
import type { InternalAxiosRequestConfig } from "axios";
import API from "./api";

let isRefreshing = false;
let refreshSubscribers: ((token: string) => void)[] = [];

const onRefreshed = (newToken: string) => {
    refreshSubscribers.forEach((cb) => cb(newToken));
    refreshSubscribers = [];
};

export const refreshTokenIfNeeded = async (error: AxiosError): Promise<unknown> => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    if (
        error.response?.status === 401 &&
        !originalRequest._retry
    ) {
        originalRequest._retry = true;

        if (!isRefreshing) {
            isRefreshing = true;

            try {
                const res = await axios.post("https://localhost:5001/api/auth/refresh", null, {
                    withCredentials: true,
                });

                const newToken: string = res.data.accessToken;
                localStorage.setItem("token", newToken);
                onRefreshed(newToken);
                isRefreshing = false;

                if (originalRequest.headers && typeof originalRequest.headers.set === "function") {
                    originalRequest.headers.set("Authorization", `Bearer ${newToken}`);
                }

                return API(originalRequest);
            } catch (refreshError) {
                isRefreshing = false;
                localStorage.removeItem("token");
                localStorage.removeItem("user");
                window.location.href = "/login";
                return Promise.reject(refreshError);
            }
        }

        return new Promise((resolve) => {
            refreshSubscribers.push((newToken: string) => {
                if (originalRequest.headers && typeof originalRequest.headers.set === "function") {
                    originalRequest.headers.set("Authorization", `Bearer ${newToken}`);
                }
                resolve(API(originalRequest));
            });
        });
    }

    return Promise.reject(error);
};

// Globalna obsługa odpowiedzi
API.interceptors.response.use(
    (res) => res,
    (err: unknown) => {
        if (axios.isAxiosError(err)) {
            return refreshTokenIfNeeded(err);
        }
        return Promise.reject(err);
    }
);
