export default function Dashboard() {
    return (
        <div>
            <h1 style={{ marginBottom: '1.5rem', fontSize: '1.8rem', fontWeight: 'bold' }}>ملخص النظام</h1>
            <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
                gap: '1.5rem'
            }}>
                <div style={{
                    backgroundColor: 'white',
                    padding: '1.5rem',
                    borderRadius: '12px',
                    boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
                }}>
                    <h3 style={{ color: '#6b7280', fontSize: '0.875rem', marginBottom: '0.5rem' }}>إجمالي المعدات</h3>
                    <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#111827', margin: 0 }}>--</p>
                </div>

                <div style={{
                    backgroundColor: 'white',
                    padding: '1.5rem',
                    borderRadius: '12px',
                    boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
                }}>
                    <h3 style={{ color: '#6b7280', fontSize: '0.875rem', marginBottom: '0.5rem' }}>المستخدمين النشطين</h3>
                    <p style={{ fontSize: '2rem', fontWeight: 'bold', color: '#111827', margin: 0 }}>--</p>
                </div>
            </div>

            <div style={{ marginTop: '2rem', padding: '1.5rem', backgroundColor: '#eff6ff', borderRadius: '12px', color: '#1e40af' }}>
                مرحباً بك في لوحة تحكم Tools Hub الجديدة! (نسخة React التجريبية)
            </div>
        </div>
    );
}
