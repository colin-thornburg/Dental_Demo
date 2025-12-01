interface MetricCardProps {
  title: string;
  value: string;
  loading: boolean;
  icon: React.ReactNode;
  color: 'blue' | 'green' | 'purple' | 'orange';
  onClick: () => void;
}

const colorClasses = {
  blue: 'from-blue-500 to-blue-600',
  green: 'from-green-500 to-green-600',
  purple: 'from-purple-500 to-purple-600',
  orange: 'from-orange-500 to-orange-600'
};

export default function MetricCard({ title, value, loading, icon, color, onClick }: MetricCardProps) {
  return (
    <button
      onClick={onClick}
      disabled={loading}
      className="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-lg hover:border-blue-300 transition-all duration-200 text-left w-full disabled:opacity-50 disabled:cursor-not-allowed group"
    >
      <div className="flex items-center justify-between mb-4">
        <div className={`w-12 h-12 bg-gradient-to-br ${colorClasses[color]} rounded-lg flex items-center justify-center text-white group-hover:scale-110 transition-transform duration-200`}>
          {icon}
        </div>
      </div>
      <h3 className="text-sm font-medium text-gray-600 mb-1">{title}</h3>
      {loading ? (
        <div className="flex items-center gap-2">
          <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-gray-900"></div>
          <p className="text-sm text-gray-500">Loading...</p>
        </div>
      ) : (
        <>
          <p className="text-2xl font-bold text-gray-900">{value}</p>
          <p className="text-xs text-gray-400 mt-2">
            {value === '--' ? '👆 Click to load data' : '✓ Data loaded'}
          </p>
        </>
      )}
    </button>
  );
}

