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
    <div className="bg-[#efefef] min-h-screen">
      <div className="max-w-4xl mx-auto bg-[#f0e0d6] border border-[#666]">
        <div className="bg-[#800000] text-white p-2">
          <h1 className="text-base font-ms-gothic">掲示板</h1>
        </div>

        <div className="p-2 border-b border-[#666]">
          <form onSubmit={handleSubmit}>
            <div className="flex flex-wrap gap-1 mb-2">
              <div className="flex-1 max-w-[200px]">
                <input
                  type="text"
                  name="name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="名前"
                  className="w-full px-1 border border-[#666] bg-[#ffffff] text-sm"
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
                  className="cursor-pointer bg-[#ffffff] px-2 border border-[#666] inline-block text-sm"
                >
                  画像
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
                className="w-full p-1 border border-[#666] bg-[#ffffff] h-24 text-sm"
              />
            </div>
            <button
              type="submit"
              className="bg-[#ffffff] px-2 border border-[#666] text-sm"
            >
              書き込む
            </button>
          </form>
        </div>

        <div>
          {messages.map((message, index) => (
            <div
              key={message.id}
              className={`p-2 ${
                message.parentId ? "ml-6 border-l border-[#666]" : ""
              }`}
            >
              <div className="flex items-start gap-2 text-sm">
                <div className="flex items-center gap-1 text-[#117743]">
                  <div className="min-w-[50px]">
                    {message.avatar ? (
                      <img
                        src={message.avatar}
                        alt="ユーザーアイコン"
                        className="w-6 h-6 border border-[#666]"
                      />
                    ) : (
                      <i className="fas fa-user-circle text-xl"></i>
                    )}
                  </div>
                  <span className="font-ms-gothic">{message.author}</span>
                </div>
                <span className="text-[#666]">#{message.id}</span>
                <span className="text-[#666]">{message.timestamp}</span>
              </div>
              <p className="mt-1 whitespace-pre-wrap font-ms-gothic text-sm pl-[58px]">
                {message.content}
              </p>
              <div className="pl-[58px]">
                <button
                  onClick={() => handleReply(message.id)}
                  className="mt-1 text-[#00e] hover:underline text-sm"
                >
                  返信
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}



