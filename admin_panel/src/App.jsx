import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import Layout from './components/Layout/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';

// Placeholder for Equipment page (we'll implement next)
const EquipmentList = () => <div>صفحة المعدات (قيد الإنشاء)</div>;

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<Login />} />

          {/* Protected Admin Routes */}
          <Route element={<Layout />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/equipment" element={<EquipmentList />} />
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
