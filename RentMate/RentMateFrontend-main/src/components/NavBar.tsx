import { Link, useLocation } from "react-router-dom";
import React from "react";

const NavBar: React.FC = () => {
  const { pathname } = useLocation();

  const linkClass = (path: string) =>
    pathname === path
      ? "text-blue-600 font-semibold"
      : "text-gray-600 hover:text-blue-600 transition";

  return (
    <nav className="bg-white shadow-md px-6 py-4 flex justify-between items-center w-full">
      <Link to="/" className="text-2xl font-bold text-blue-700">
        RentMate
      </Link>
      <div className="flex gap-6 text-lg">
        <Link to="/" className={linkClass("/")}>
          Home
        </Link>
        <Link to="/properties" className={linkClass("/properties")}>
          Oferty
        </Link>
        <Link to="/dashboard" className={linkClass("/dashboard")}>
          Panel
        </Link>
        <Link to="/login" className={linkClass("/login")}>
          Logowanie
        </Link>
        <Link to="/register" className={linkClass("/register")}>
          Rejestracja
        </Link>
        <Link to="/add-property" className={linkClass("/add-property")}>
          Dodaj ogłoszenie
        </Link>
        <Link to="/my-properties">Moje mieszkania</Link>
      </div>
    </nav>
  );
};

export default NavBar;
