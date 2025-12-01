'use client';

import { useState } from 'react';
import { Send, BarChart3, TrendingUp, Users, DollarSign } from 'lucide-react';
import MetricCard from '@/components/MetricCard';
import ChatMessage from '@/components/ChatMessage';
import QueryResults from '@/components/QueryResults';

export default function Home() {
  const [query, setQuery] = useState('');
  const [messages, setMessages] = useState<Array<{role: string, content: string, data?: any}>>([]);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    const userMessage = { role: 'user', content: query };
    setMessages(prev => [...prev, userMessage]);
    setLoading(true);
    setQuery('');

    try {
      const response = await fetch('http://localhost:5001/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query })
      });

      const data = await response.json();
      
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: `I found data for your query: "${query}"`,
        data: data
      }]);
    } catch (error) {
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: 'Sorry, I encountered an error processing your query. Please make sure the backend server is running.'
      }]);
    } finally {
      setLoading(false);
    }
  };

  const quickQueries = [
    "Show me revenue by brand for 2024",
    "What's the no-show rate by facility?",
    "Show new patient visits by month",
    "Compare gross profit across all brands"
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-blue-800 rounded-lg flex items-center justify-center">
                <BarChart3 className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">TAG Analytics</h1>
                <p className="text-sm text-gray-500">Powered by dbt Semantic Layer</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-sm font-medium text-gray-600">The Aspen Group</p>
              <p className="text-xs text-gray-400">Putting care back in healthcare</p>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Quick Metrics */}
        {messages.length === 0 && (
          <div className="mb-8">
            <h2 className="text-lg font-semibold text-gray-700 mb-4">Quick Metrics</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <MetricCard
                title="Total Revenue"
                icon={<DollarSign className="w-5 h-5" />}
                color="blue"
              />
              <MetricCard
                title="Patient Visits"
                icon={<Users className="w-5 h-5" />}
                color="green"
              />
              <MetricCard
                title="Growth Rate"
                icon={<TrendingUp className="w-5 h-5" />}
                color="purple"
              />
              <MetricCard
                title="Active Facilities"
                icon={<BarChart3 className="w-5 h-5" />}
                color="orange"
              />
            </div>
          </div>
        )}

        {/* Chat Messages */}
        {messages.length > 0 && (
          <div className="mb-8 space-y-4">
            {messages.map((msg, idx) => (
              <div key={idx}>
                <ChatMessage message={msg} />
                {msg.data && <QueryResults data={msg.data} />}
              </div>
            ))}
          </div>
        )}

        {/* Quick Query Suggestions */}
        {messages.length === 0 && (
          <div className="mb-8">
            <h2 className="text-lg font-semibold text-gray-700 mb-4">Try asking:</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {quickQueries.map((q, idx) => (
                <button
                  key={idx}
                  onClick={() => setQuery(q)}
                  className="text-left p-4 bg-white rounded-lg border border-gray-200 hover:border-blue-500 hover:shadow-md transition-all duration-200"
                >
                  <p className="text-sm text-gray-700">{q}</p>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Chat Input */}
        <div className="sticky bottom-0 bg-white rounded-xl shadow-lg border border-gray-200 p-4">
          <form onSubmit={handleSubmit} className="flex gap-3">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Ask about revenue, patient visits, facility performance..."
              className="flex-1 px-4 py-3 bg-gray-50 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              disabled={loading}
            />
            <button
              type="submit"
              disabled={loading || !query.trim()}
              className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors duration-200 flex items-center gap-2"
            >
              {loading ? (
                <span className="animate-spin">⏳</span>
              ) : (
                <Send className="w-5 h-5" />
              )}
              Send
            </button>
          </form>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-6 text-sm text-gray-500">
              <a href="https://www.teamtag.com/" target="_blank" rel="noopener noreferrer" className="hover:text-blue-600">
                About TAG
              </a>
              <span>•</span>
              <span>Aspen Dental</span>
              <span>•</span>
              <span>ClearChoice</span>
              <span>•</span>
              <span>WellNow</span>
              <span>•</span>
              <span>Chapter</span>
              <span>•</span>
              <span>Lovet</span>
            </div>
            <p className="text-sm text-gray-400">© 2025 TAG - The Aspen Group</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
