import React, { useState, useEffect } from 'react';
import { useAuth } from '../AuthContext';
import { useNavigate } from 'react-router-dom';
import { FiMap, FiLogOut, FiActivity, FiNavigation, FiUser } from 'react-icons/fi';
import { LineChart, Line, ResponsiveContainer } from 'recharts';

const Dashboard = () => {
  const { currentUser, signOut } = useAuth();
  const navigate = useNavigate();
  
  // Mock State for UI
  const [fuelPercentage, setFuelPercentage] = useState(80.0);
  const [estDistance, setEstDistance] = useState(24.5);
  const [litersLeft, setLitersLeft] = useState(2.1);
  const [mockData, setMockData] = useState([]);
  
  useEffect(() => {
    // Generate initial flat mock data
    const initialData = Array.from({length: 10}).map((_, i) => ({ val: 80 }));
    setMockData(initialData);
  }, []);

  const handleLogout = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch(err) {
      console.error(err);
    }
  };

  const simulateData = () => {
    // Randomize fuel drop
    const newFuel = Math.max(0, fuelPercentage - (Math.random() * 5));
    setFuelPercentage(newFuel);
    setEstDistance((newFuel / 100) * 30); // simplistic math
    setLitersLeft((newFuel / 100) * 5); // assuming 5L tank

    setMockData(prev => {
      const next = [...prev, { val: newFuel }];
      if(next.length > 10) next.shift();
      return next;
    });
  };

  // Ring styling
  let ringColor = '#00FF7F';
  if (fuelPercentage < 20) ringColor = '#FF3B30';
  else if (fuelPercentage < 50) ringColor = '#FF9500';

  return (
    <div className="dashboard-container">
      <nav className="navbar">
        <h1>Smart Dashboard</h1>
        <div className="nav-actions">
          <button onClick={() => alert("Map View Coming Soon")} title="Nearby Stations"><FiMap /></button>
          <button onClick={handleLogout} title="Logout"><FiLogOut /></button>
        </div>
      </nav>

      <div style={{ marginTop: '24px' }}>
        <h2 style={{ fontSize: '22px', fontWeight: '600' }}>Vehicle: Honda Civic</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Licence Plate: B 4567 CD</p>
      </div>

      {/* Fuel Ring */}
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        margin: '40px 0' 
      }}>
        <div style={{
          width: '240px',
          height: '240px',
          borderRadius: '50%',
          border: `8px solid ${ringColor}`,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: `0 0 30px ${ringColor}40`,
          transition: 'all 0.5s ease'
        }}>
          <h1 style={{ fontSize: '48px', color: ringColor, margin: 0 }}>
            {fuelPercentage.toFixed(1)}%
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>Fuel Remaining</p>
        </div>
      </div>

      {/* Metrics Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '24px' }}>
        <div className="auth-card" style={{ padding: '24px', width: 'auto', display: 'flex', alignItems: 'center', gap: '16px' }}>
          <FiNavigation size={32} color={ringColor} />
          <div>
            <h3 style={{ fontSize: '24px', margin: 0 }}>{estDistance.toFixed(1)} km</h3>
            <p style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>Est. Distance</p>
          </div>
        </div>
        <div className="auth-card" style={{ padding: '24px', width: 'auto', display: 'flex', alignItems: 'center', gap: '16px' }}>
          <FiActivity size={32} color={ringColor} />
          <div>
            <h3 style={{ fontSize: '24px', margin: 0 }}>{litersLeft.toFixed(1)} L</h3>
            <p style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>Liters Left</p>
          </div>
        </div>
      </div>

      {/* Context Chips */}
      <div style={{ display: 'flex', justifyContent: 'space-around', background: 'var(--panel-bg)', padding: '16px', borderRadius: '12px', border: '1px solid rgba(255,255,255,0.05)', marginBottom: '32px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', fontSize: '14px' }}>
          <span style={{ color: ringColor }}>🚥</span> Moderate
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', fontSize: '14px' }}>
          <span style={{ color: ringColor }}>⏱️</span> 65 km/h
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', fontSize: '14px' }}>
          <FiUser color={ringColor} /> Eco
        </div>
      </div>

      {/* Chart */}
      <div className="auth-card" style={{ width: '100%', padding: '24px', textAlign: 'left' }}>
        <h3 style={{ marginBottom: '16px', fontSize: '16px' }}>Fuel Usage History</h3>
        <div style={{ height: '150px', width: '100%' }}>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={mockData}>
              <Line 
                type="monotone" 
                dataKey="val" 
                stroke={ringColor} 
                strokeWidth={3}
                dot={false}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <button className="btn-primary" onClick={simulateData} style={{ marginTop: '32px' }}>
        Simulate Data Pushed
      </button>

    </div>
  );
};

export default Dashboard;
