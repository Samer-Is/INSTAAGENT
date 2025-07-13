import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { format } from 'date-fns';
import { Plus, Trash2, Shield, Search } from 'lucide-react';
import { apiClient } from '../lib/api';
import { CreateWhitelistRequest } from '../types';
import type { WhitelistEntry } from '../types';
import { toast } from 'sonner';

const addWhitelistSchema = z.object({
  pageId: z.string().min(1, 'Page ID is required'),
  merchantName: z.string().min(1, 'Merchant name is required').max(200, 'Merchant name too long'),
});

type AddWhitelistFormData = z.infer<typeof addWhitelistSchema>;

const Whitelist: React.FC = () => {
  const queryClient = useQueryClient();
  const [showAddForm, setShowAddForm] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setError,
  } = useForm<AddWhitelistFormData>({
    resolver: zodResolver(addWhitelistSchema),
  });

  // Fetch whitelist
  const { data: whitelist = [], isLoading, error } = useQuery({
    queryKey: ['whitelist'],
    queryFn: () => apiClient.getWhitelist(),
  });

  // Add to whitelist mutation
  const addMutation = useMutation({
    mutationFn: (data: CreateWhitelistRequest) => apiClient.addToWhitelist(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['whitelist'] });
      reset();
      setShowAddForm(false);
    },
    onError: (error: any) => {
      const message = error.response?.data?.error || 'Failed to add merchant to whitelist';
      setError('root', { message });
    },
  });

  // Remove from whitelist mutation
  const removeMutation = useMutation({
    mutationFn: (id: string) => apiClient.removeFromWhitelist(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['whitelist'] });
    },
    onError: (error: any) => {
      const message = error.response?.data?.error || 'Failed to remove merchant from whitelist';
      toast.error(message);
    },
  });

  const onSubmit = (data: AddWhitelistFormData) => {
    addMutation.mutate(data);
  };

  const handleRemove = (id: string, merchantName: string) => {
    if (window.confirm(`Are you sure you want to remove "${merchantName}" from the whitelist?`)) {
      removeMutation.mutate(id);
    }
  };

  // Filter whitelist based on search term
  const filteredWhitelist = whitelist.filter(
    (entry) =>
      entry.merchantName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      entry.pageId.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="rounded-md bg-red-50 p-4">
        <p className="text-sm text-red-600">Failed to load whitelist. Please try again.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Whitelist Management</h1>
          <p className="text-gray-600">Manage which Instagram pages can access the platform</p>
        </div>
        <button
          onClick={() => setShowAddForm(true)}
          className="btn-primary"
        >
          <Plus className="h-4 w-4 mr-2" />
          Add Merchant
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type="text"
          placeholder="Search merchants or page IDs..."
          className="input pl-10"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {/* Add Form Modal */}
      {showAddForm && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h2 className="text-lg font-semibold mb-4">Add Merchant to Whitelist</h2>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Merchant Name
                </label>
                <input
                  {...register('merchantName')}
                  type="text"
                  className={`input ${errors.merchantName ? 'border-red-500' : ''}`}
                  placeholder="Enter merchant name"
                />
                {errors.merchantName && (
                  <p className="mt-1 text-sm text-red-600">{errors.merchantName.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Instagram Page ID
                </label>
                <input
                  {...register('pageId')}
                  type="text"
                  className={`input ${errors.pageId ? 'border-red-500' : ''}`}
                  placeholder="Enter Instagram page ID"
                />
                {errors.pageId && (
                  <p className="mt-1 text-sm text-red-600">{errors.pageId.message}</p>
                )}
              </div>

              {errors.root && (
                <div className="rounded-md bg-red-50 p-4">
                  <p className="text-sm text-red-600">{errors.root.message}</p>
                </div>
              )}

              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowAddForm(false);
                    reset();
                  }}
                  className="btn-secondary"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={addMutation.isPending}
                  className="btn-primary"
                >
                  {addMutation.isPending ? 'Adding...' : 'Add to Whitelist'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="card p-4">
          <div className="flex items-center">
            <Shield className="h-8 w-8 text-primary-600" />
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Total Whitelisted</p>
              <p className="text-2xl font-bold text-gray-900">{whitelist.length}</p>
            </div>
          </div>
        </div>
        <div className="card p-4">
          <div className="flex items-center">
            <Search className="h-8 w-8 text-green-600" />
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Filtered Results</p>
              <p className="text-2xl font-bold text-gray-900">{filteredWhitelist.length}</p>
            </div>
          </div>
        </div>
        <div className="card p-4">
          <div className="flex items-center">
            <Plus className="h-8 w-8 text-blue-600" />
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-500">Recently Added</p>
              <p className="text-2xl font-bold text-gray-900">
                {whitelist.filter(entry => 
                  new Date(entry.createdAt) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
                ).length}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Whitelist Table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="table">
            <thead>
              <tr>
                <th>Merchant Name</th>
                <th>Page ID</th>
                <th>Added Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredWhitelist.length === 0 ? (
                <tr>
                  <td colSpan={4} className="text-center py-8 text-gray-500">
                    {searchTerm ? 'No merchants found matching your search.' : 'No merchants in whitelist yet.'}
                  </td>
                </tr>
              ) : (
                filteredWhitelist.map((entry) => (
                  <tr key={entry.id}>
                    <td className="font-medium">{entry.merchantName}</td>
                    <td className="font-mono text-sm">{entry.pageId}</td>
                    <td>{format(new Date(entry.createdAt), 'MMM d, yyyy')}</td>
                    <td>
                      <button
                        onClick={() => handleRemove(entry.id, entry.merchantName)}
                        disabled={removeMutation.isPending}
                        className="btn-danger text-xs"
                      >
                        <Trash2 className="h-3 w-3 mr-1" />
                        Remove
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Whitelist; 