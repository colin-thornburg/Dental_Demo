'use client';

import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

interface QueryResultsProps {
  data: {
    parsed_query?: {
      metrics: string[];
      dimensions: string[];
    };
    result?: {
      success: boolean;
      output?: string;
      error?: string;
    };
  };
}

export default function QueryResults({ data }: QueryResultsProps) {
  if (!data.result) return null;

  if (!data.result.success) {
    return (
      <div className="mt-4 bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-sm font-medium text-red-800">Error executing query</p>
        <p className="text-xs text-red-600 mt-1">{data.result.error}</p>
      </div>
    );
  }

  // Parse the output - this is a simplified parser for the ASCII table format
  const parseTable = (output: string) => {
    if (!output) return { headers: [], rows: [] };
    
    const lines = output.split('\n').filter(line => line.trim());
    const dataLines = lines.filter(line => line.startsWith('|') && !line.includes('---'));
    
    if (dataLines.length < 2) return { headers: [], rows: [] };
    
    const headerLine = dataLines[0];
    const headers = headerLine.split('|')
      .map(h => h.trim())
      .filter(h => h && h !== '+')
      .map(h => h.replace(/_/g, ' '));
    
    const rows = dataLines.slice(1).map(line => {
      const values = line.split('|')
        .map(v => v.trim())
        .filter(v => v && v !== '+');
      
      return headers.reduce((obj, header, idx) => {
        obj[header] = values[idx] || '';
        return obj;
      }, {} as Record<string, string>);
    });
    
    return { headers, rows };
  };

  const { headers, rows } = parseTable(data.result.output || '');

  if (rows.length === 0) {
    return (
      <div className="mt-4 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <p className="text-sm text-yellow-800">No data returned from query</p>
      </div>
    );
  }

  return (
    <div className="mt-4 bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
      <div className="mb-4">
        <h3 className="text-sm font-semibold text-gray-700 mb-2">Query Details</h3>
        <div className="flex flex-wrap gap-2">
          {data.parsed_query?.metrics?.map((m, idx) => (
            <span key={idx} className="px-3 py-1 bg-blue-100 text-blue-800 text-xs font-medium rounded-full">
              {m}
            </span>
          ))}
          {data.parsed_query?.dimensions?.map((d, idx) => (
            <span key={idx} className="px-3 py-1 bg-purple-100 text-purple-800 text-xs font-medium rounded-full">
              {d.replace(/__/g, ' › ')}
            </span>
          ))}
        </div>
      </div>

      {/* Table View */}
      <div className="overflow-x-auto mb-6">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              {headers.map((header, idx) => (
                <th key={idx} className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {rows.map((row, idx) => (
              <tr key={idx} className="hover:bg-gray-50">
                {headers.map((header, colIdx) => (
                  <td key={colIdx} className="px-4 py-3 text-sm text-gray-900">
                    {row[header]}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Chart View - if we have numeric data */}
      {rows.length > 0 && headers.length >= 2 && (
        <div className="mt-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-4">Visualization</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={rows}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                dataKey={headers[0]} 
                angle={-45} 
                textAnchor="end" 
                height={100}
                tick={{ fontSize: 12 }}
              />
              <YAxis tick={{ fontSize: 12 }} />
              <Tooltip />
              <Legend />
              {headers.slice(1).map((header, idx) => {
                const colors = ['#3b82f6', '#10b981', '#8b5cf6', '#f59e0b', '#ef4444'];
                return (
                  <Bar 
                    key={header} 
                    dataKey={header} 
                    fill={colors[idx % colors.length]}
                    name={header}
                  />
                );
              })}
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      <div className="mt-4 pt-4 border-t border-gray-200">
        <p className="text-xs text-gray-400">
          Showing {rows.length} row{rows.length !== 1 ? 's' : ''}
        </p>
      </div>
    </div>
  );
}

