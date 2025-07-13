import React from 'react';
import { Settings as SettingsIcon, Clock } from 'lucide-react';

const Settings: React.FC = () => {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="text-gray-600">Configure platform settings and preferences</p>
      </div>

      {/* Coming Soon Card */}
      <div className="card p-12 text-center">
        <div className="mx-auto h-16 w-16 flex items-center justify-center rounded-full bg-gray-100 mb-6">
          <SettingsIcon className="h-8 w-8 text-gray-400" />
        </div>
        <h3 className="text-lg font-semibold text-gray-900 mb-2">Coming Soon</h3>
        <p className="text-gray-600 mb-6 max-w-md mx-auto">
          Platform settings and configuration options will be available in future phases. 
          This will include system preferences, notification settings, and security configurations.
        </p>
        <div className="inline-flex items-center px-4 py-2 rounded-full bg-blue-100 text-blue-800 text-sm font-medium">
          <Clock className="h-4 w-4 mr-2" />
          Future Feature
        </div>
      </div>

      {/* Feature Preview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="card p-6">
          <h4 className="font-semibold text-gray-900 mb-2">System Configuration</h4>
          <p className="text-sm text-gray-600">
            Configure global platform settings, rate limits, and system preferences.
          </p>
        </div>
        <div className="card p-6">
          <h4 className="font-semibold text-gray-900 mb-2">Security Settings</h4>
          <p className="text-sm text-gray-600">
            Manage authentication settings, API keys, and security policies.
          </p>
        </div>
        <div className="card p-6">
          <h4 className="font-semibold text-gray-900 mb-2">Notification Preferences</h4>
          <p className="text-sm text-gray-600">
            Configure email notifications, alerts, and reporting preferences.
          </p>
        </div>
      </div>
    </div>
  );
};

export default Settings; 