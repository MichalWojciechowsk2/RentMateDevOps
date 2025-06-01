
import React from 'react';
import { Link } from 'react-router-dom';

const HomePage = () => {
    return (
        <main className="flex flex-col items-center justify-center h-screen p-8 text-center">
            <h1 className="text-4xl font-bold mb-4">Witaj w RentMate</h1>
            <div className="flex gap-4">
                <Link to="/login" className="px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700">
                    Zaloguj się
                </Link>
                <Link to="/properties" className="px-6 py-3 bg-gray-200 rounded hover:bg-gray-300">
                    Przeglądaj oferty
                </Link>
            </div>
        </main>
    );
};

export default HomePage;
