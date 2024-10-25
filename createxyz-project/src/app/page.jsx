"use client";
import React from "react";

function MainComponent() {
  const [messages, setMessages] = React.useState([
    {
      id: 1,
      author: "匿名さん",
      content: "こんにちは！",
      timestamp: "2024-01-01 12:00",
      avatar: "",
      parentId: null,
    },
    {
      id: 2,
      author: "名無しさん",
      content: "お気軽に書き込んでください",
      timestamp: "2024-01-01 12:05",
      avatar: "",
      parentId: null,
    },
  ]);
  const [newMessage, setNewMessage] = React.useState("");
  const [name, setName] = React.useState("");
  const [avatar, setAvatar] = React.useState("");
  const [replyTo, setReplyTo] = React.useState(null);

  const handleImageUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setAvatar(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!newMessage.trim()) return;

    const message = {
      id: messages.length + 1,
      author: name.trim() || "名無しさん",
      content: newMessage,
      timestamp: new Date().toLocaleString(),
      avatar: avatar,
      parentId: replyTo,
    };

    setMessages([...messages, message]);
    setNewMessage("");
    setReplyTo(null);
  };

  const handleReply = (messageId) => {
    setReplyTo(messageId);
  };

  return (
    <div className="min-h-screen bg-[#fffaf0] p-4">
      <div className="max-w-2xl mx-auto">
        <h1 className="text-2xl font-bold mb-6 text-[#006400] font-ms-gothic">
          掲示板
        </h1>

        <div className="bg-white p-4 rounded-lg shadow mb-6">
          <form onSubmit={handleSubmit} className="space-y-3">
            <div className="flex gap-4">
              <div className="flex-1">
                <input
                  type="text"
                  name="name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="名前（省略可）"
                  className="w-full p-2 border border-gray-300 rounded"
                />
              </div>
              <div>
                <input
                  type="file"
                  name="avatar"
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                  id="avatar-upload"
                />
                <label
                  htmlFor="avatar-upload"
                  className="cursor-pointer bg-gray-100 px-4 py-2 rounded border border-gray-300 inline-block"
                >
                  <i className="fas fa-user-circle mr-2"></i>アイコン選択
                </label>
              </div>
            </div>
            {replyTo && (
              <div className="bg-gray-100 p-2 rounded">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">
                    返信中: #{replyTo}
                  </span>
                  <button
                    type="button"
                    onClick={() => setReplyTo(null)}
                    className="text-gray-500 hover:text-gray-700"
                  >
                    <i className="fas fa-times"></i>
                  </button>
                </div>
              </div>
            )}
            <div>
              <textarea
                name="message"
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="メッセージを入力"
                className="w-full p-2 border border-gray-300 rounded h-24"
              />
            </div>
            <button
              type="submit"
              className="bg-[#4169e1] hover:bg-[#1e90ff] text-white px-4 py-2 rounded"
            >
              書き込む
            </button>
          </form>
        </div>

        <div className="space-y-4">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`bg-white p-4 rounded-lg shadow ${
                message.parentId ? "ml-8 border-l-4 border-gray-200" : ""
              }`}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-2">
                  {message.avatar ? (
                    <img
                      src={message.avatar}
                      alt="ユーザーアイコン"
                      className="w-8 h-8 rounded-full object-cover"
                    />
                  ) : (
                    <i className="fas fa-user-circle text-2xl text-gray-400"></i>
                  )}
                  <span className="font-bold text-[#006400] font-ms-gothic">
                    {message.author} #{message.id}
                  </span>
                </div>
                <span className="text-sm text-gray-500">
                  {message.timestamp}
                </span>
              </div>
              <p className="mt-2 whitespace-pre-wrap font-ms-gothic">
                {message.content}
              </p>
              <button
                onClick={() => handleReply(message.id)}
                className="mt-2 text-[#4169e1] hover:text-[#1e90ff] text-sm"
              >
                <i className="fas fa-reply mr-1"></i>返信する
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default MainComponent;