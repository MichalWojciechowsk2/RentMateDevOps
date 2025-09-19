import { useAuth } from "../context/AuthContext";

const DashboardPage = () => {
  const { user, logout } = useAuth();

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Panel użytkownika</h1>
      {user ? (
        <>
          <p className="mb-2">Witaj, <strong>{user.username}</strong>!</p>
          <p>Email: <strong>{user.email}</strong></p>
          <p>Rola: <strong>{user.role}</strong></p>
          <p>ID konta: <strong>{user.id}</strong></p>

          <button
            onClick={logout}
            className="mt-4 bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
          >
            Wyloguj się
          </button>
        </>
      ) : (
        <p className="text-red-600">Nie jesteś zalogowany.</p>
      )}
    </div>
  );
};

export default DashboardPage;
