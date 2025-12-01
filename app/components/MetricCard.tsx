interface MetricCardProps {
  title: string;
  icon: React.ReactNode;
  color: 'blue' | 'green' | 'purple' | 'orange';
}

const colorClasses = {
  blue: 'from-blue-500 to-blue-600',
  green: 'from-green-500 to-green-600',
  purple: 'from-purple-500 to-purple-600',
  orange: 'from-orange-500 to-orange-600'
};

export default function MetricCard({ title, icon, color }: MetricCardProps) {
  return (
    <div className="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-lg transition-shadow duration-200">
      <div className="flex items-center justify-between mb-4">
        <div className={`w-12 h-12 bg-gradient-to-br ${colorClasses[color]} rounded-lg flex items-center justify-center text-white`}>
          {icon}
        </div>
      </div>
      <h3 className="text-sm font-medium text-gray-600 mb-1">{title}</h3>
      <p className="text-2xl font-bold text-gray-900">--</p>
      <p className="text-xs text-gray-400 mt-2">Query to see data</p>
    </div>
  );
}

