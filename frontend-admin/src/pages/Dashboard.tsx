import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Shield, Users, BarChart3, Clock } from 'lucide-react';
import { apiClient } from '../lib/api';

const Dashboard: React.FC = () => {
  const { data: whitelist = [], isLoading } = useQuery({
    queryKey: ['whitelist'],
    queryFn: () => apiClient.getWhitelist(),
  });

  const stats = [
    {
      name: 'Total Whitelisted',
      value: whitelist.length,
      icon: Shield,
      color: 'text-primary-600',
      bgColor: 'bg-primary-100',
    },
    {
      name: 'Active Merchants',
      value: '0', // Placeholder - will be implemented in Phase 2
      icon: Users,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      name: 'Messages Processed',
      value: '0', // Placeholder - will be implemented in Phase 3
      icon: BarChart3,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      name: 'Uptime',
      value: '99.9%',
      icon: Clock,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
  ];

  const recentActivity = [
    {
      id: 1,
      action: 'Whitelist updated',
      description: 'New merchant added to whitelist',
      time: '2 hours ago',
      type: 'success',
    },
    {
      id: 2,
      action: 'System startup',
      description: 'Admin dashboard initialized',
      time: '1 day ago',
      type: 'info',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600">Overview of your Instagram AI Agent platform</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <div key={stat.name} className="card p-6">
              <div className="flex items-center">
                <div className={`p-2 rounded-lg ${stat.bgColor}`}>
                  <Icon className={`h-6 w-6 ${stat.color}`} />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-500">{stat.name}</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {isLoading ? '...' : stat.value}
                  </p>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Activity */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
          <div className="space-y-4">
            {recentActivity.map((activity) => (
              <div key={activity.id} className="flex items-start space-x-3">
                <div
                  className={`w-2 h-2 rounded-full mt-2 ${
                    activity.type === 'success' ? 'bg-green-500' : 'bg-blue-500'
                  }`}
                />
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-900">{activity.action}</p>
                  <p className="text-sm text-gray-500">{activity.description}</p>
                  <p className="text-xs text-gray-400 mt-1">{activity.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* System Status */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">System Status</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Database</span>
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                Healthy
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">API Server</span>
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                Online
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">AI Service</span>
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                Pending
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-gray-600">Webhooks</span>
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                Pending
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="btn-primary justify-start">
            <Shield className="h-4 w-4 mr-2" />
            Manage Whitelist
          </button>
          <button className="btn-secondary justify-start" disabled>
            <Users className="h-4 w-4 mr-2" />
            View Merchants
            <span className="ml-2 text-xs bg-gray-200 px-2 py-1 rounded">Phase 2</span>
          </button>
          <button className="btn-secondary justify-start" disabled>
            <BarChart3 className="h-4 w-4 mr-2" />
            Analytics
            <span className="ml-2 text-xs bg-gray-200 px-2 py-1 rounded">Phase 7</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard; 