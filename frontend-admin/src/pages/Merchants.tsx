import React from 'react';
import { Users, Clock } from 'lucide-react';

const Merchants: React.FC = () => {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Merchants</h1>
        <p className="text-gray-600">Manage active merchants and their configurations</p>
      </div>

      {/* Coming Soon Card */}
      <div className="card p-12 text-center">
        <div className="mx-auto h-16 w-16 flex items-center justify-center rounded-full bg-gray-100 mb-6">
          <Users className="h-8 w-8 text-gray-400" />
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">Coming Soon</h3>
        <p className="text-gray-600 mb-6 max-w-md mx-auto">
          Merchant management functionality will be available in Phase 2. This will include viewing 
          active merchants, their configurations, and onboarding status.
        </p>
        <div className="inline-flex items-center px-4 py-2 rounded-full bg-blue-100 text-blue-800 text-sm font-medium">
          <Clock className="h-4 w-4 mr-2" />
          Phase 2 Feature
        </div>
      </div>

      {/* Feature Preview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="card p-6">
          <h4 className="font-semibold text-gray-900 mb-2">Merchant Overview</h4>
          <p className="text-sm text-gray-600">
            View all onboarded merchants with their business information and status.
          </p>
        </div>
        <div className="card p-6">
          <h4 className="font-semibold text-gray-900 mb-2">Configuration Management</h4>
          <p className="text-sm text-gray-600">
            Manage merchant AI settings, business rules, and product catalogs.
          </p>
        </div>
        <div className="card p-6">
          <h4 className="font-semibold text-gray-900 mb-2">Performance Metrics</h4>
          <p className="text-sm text-gray-600">
            Track merchant engagement, message volumes, and conversion rates.
          </p>
        </div>
      </div>
    </div>
  );
};

export default Merchants; 