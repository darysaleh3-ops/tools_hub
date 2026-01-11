import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Lock, Mail, AlertCircle } from 'lucide-react';
import '../styles/Login.css'; // We'll create this next

export default function Login() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    async function handleSubmit(e) {
        e.preventDefault();

        try {
            setError('');
            setLoading(true);
            await login(email, password);
            navigate('/');
        } catch (err) {
            console.error(err);
            setError('فشل تسجيل الدخول. تأكد من البيانات وصلاحيات المشرف.');
        }
        setLoading(false);
    }

    return (
        <div className="login-container">
            <div className="login-card">
                <div className="login-header">
                    <div className="logo-icon">
                        <Lock size={32} color="white" />
                    </div>
                    <h1>بوابة المشرفين</h1>
                    <p>Tools Hub Admin</p>
                </div>

                {error && (
                    <div className="error-alert">
                        <AlertCircle size={16} />
                        <span>{error}</span>
                    </div>
                )}

                <form onSubmit={handleSubmit} className="login-form">
                    <div className="form-group">
                        <label>البريد الإلكتروني</label>
                        <div className="input-wrapper">
                            <Mail size={18} className="input-icon" />
                            <input
                                type="email"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="admin@example.com"
                            />
                        </div>
                    </div>

                    <div className="form-group">
                        <label>كلمة المرور</label>
                        <div className="input-wrapper">
                            <Lock size={18} className="input-icon" />
                            <input
                                type="password"
                                required
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="••••••••"
                            />
                        </div>
                    </div>

                    <button disabled={loading} type="submit" className="login-button">
                        {loading ? 'جاري التحقق...' : 'دخول'}
                    </button>
                </form>
            </div>
        </div>
    );
}
