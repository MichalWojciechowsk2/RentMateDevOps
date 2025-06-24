export type Role = "Tenant" | "Owner" | "Admin";

export type User = {
    id: number;
    email: string;
    username: string;
    password: string;
    role: Role;
};
