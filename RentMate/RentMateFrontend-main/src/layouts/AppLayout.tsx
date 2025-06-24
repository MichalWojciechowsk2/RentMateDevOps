import { Outlet } from "react-router-dom";
import NavBar from "../components/NavBar";

const AppLayout = () => {
  return (
    <div className="w-full min-h-screen bg-gray-100 dark:bg-gray-900 text-black dark:text-white">
      <NavBar />
      <main className="w-full p-6">
        <Outlet />
      </main>
    </div>
  );
};

export default AppLayout;
