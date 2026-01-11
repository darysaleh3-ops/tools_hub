import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Hammer, Users, LogOut } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

export default function Sidebar() {
    const { logout } = useAuth();

    return (
        <aside className="sidebar">
            <div className="sidebar-header">
                <div className="logo">ToolsHub</div>
            </div>

            <nav className="sidebar-nav">
                <NavLink
                    to="/"
                    className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                >
                    <LayoutDashboard size={20} />
                    <span>الرئيسية</span>
                </NavLink>

                <NavLink
                    to="/equipment"
                    className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                >
                    <Hammer size={20} />
                    <span>المعدات</span>
                </NavLink>

                <div className="nav-item disabled">
                    <Users size={20} />
                    <span>المستخدمين (قريباً)</span>
                </div>
            </nav>

            <div className="sidebar-footer">
                <button onClick={logout} className="logout-button">
                    <LogOut size={20} />
                    <span>تسجيل خروج</span>
                </button>
            </div>
        </aside>
    );
}
