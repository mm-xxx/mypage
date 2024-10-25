import React from 'react';

function useHandleStreamResponse({ onChunk, onFinish }) {
    const handleStreamResponse = react.useCallback(async (response)=>{
        if (response.body) {
            const reader = response.body.getReader();
            if (reader) {
                const decoder = new TextDecoder();
                let content = "";
                while(true){
                    const { done, value } = await reader.read();
                    if (done) {
                        onFinish(content);
                        break;
                    }
                    const chunk = decoder.decode(value, {
                        stream: true
                    });
                    content += chunk;
                    onChunk(content);
                }
            }
        }
    }, [
        onChunk,
        onFinish
    ]);
    return handleStreamResponse;
}

export {
  useHandleStreamResponse
}
