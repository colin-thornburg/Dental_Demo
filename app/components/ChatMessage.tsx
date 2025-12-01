import { User, Bot } from 'lucide-react';

interface ChatMessageProps {
  message: {
    role: string;
    content: string;
  };
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.role === 'user';

  return (
    <div className={`flex gap-3 ${isUser ? 'justify-end' : 'justify-start'}`}>
      {!isUser && (
        <div className="w-8 h-8 bg-gradient-to-br from-blue-600 to-blue-800 rounded-full flex items-center justify-center flex-shrink-0">
          <Bot className="w-5 h-5 text-white" />
        </div>
      )}
      <div className={`max-w-3xl ${isUser ? 'bg-blue-600 text-white' : 'bg-white border border-gray-200'} rounded-lg px-4 py-3 shadow-sm`}>
        <p className={`text-sm ${isUser ? 'text-white' : 'text-gray-800'}`}>
          {message.content}
        </p>
      </div>
      {isUser && (
        <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center flex-shrink-0">
          <User className="w-5 h-5 text-gray-600" />
        </div>
      )}
    </div>
  );
}

