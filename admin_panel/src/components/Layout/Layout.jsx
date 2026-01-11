import { Outlet, Navigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import Sidebar from './Sidebar';
import '../../styles/Layout.css'; // We'll create this

export default function Layout() {
    const { currentUser, isAdmin, loading } = useAuth();

    if (loading) {
        return <div className="loading-screen">جاري التحميل...</div>;
    }

    if (!currentUser || !isAdmin) {
        return <Navigate to="/login" replace />;
    }

    return (
        <div className="app-container">
            <Sidebar />
            <main className="main-content">
                <header className="top-bar">
                    <h2>لوحة التحكم</h2>
                    <div className="user-info">
                        <span>{currentUser.username || currentUser.email}</span>
                        <div className="avatar">
                            {currentUser.username ? currentUser.username[0] : 'A'}
                        </div>
                    </div>
                </header>
                <div className="content-area">
                    <Outlet />
                </div>
            </main>
        </div>
    );
}
