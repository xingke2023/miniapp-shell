<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatLog;
use Illuminate\Http\Request;

class ChatLogController extends Controller
{
    // POST /api/chat-logs — OpenClaw 写入，Sanctum token 鉴权
    public function store(Request $request)
    {
        $data = $request->only([
            'agent_id', 'direction', 'channel', 'account_id',
            'conversation_id', 'message_id', 'sender', 'content',
            'success', 'error_msg', 'session_key', 'occurred_at',
        ]);

        $log = ChatLog::create($data);

        return response()->json(['ok' => true, 'id' => $log->id], 201);
    }

    // GET /api/chat-logs — 后台查询，支持过滤 + 分页
    public function index(Request $request)
    {
        $query = ChatLog::query();

        if ($request->filled('agent_id')) {
            $query->where('agent_id', $request->agent_id);
        }
        if ($request->filled('conversation_id')) {
            $query->where('conversation_id', $request->conversation_id);
        }
        if ($request->filled('direction')) {
            $query->where('direction', $request->direction);
        }
        if ($request->filled('channel')) {
            $query->where('channel', $request->channel);
        }
        if ($request->filled('date_from')) {
            $query->where('occurred_at', '>=', $request->date_from);
        }
        if ($request->filled('date_to')) {
            $query->where('occurred_at', '<=', $request->date_to);
        }

        $logs = $query->orderByDesc('occurred_at')->paginate($request->integer('per_page', 50));

        return response()->json($logs);
    }

    // GET /api/chat-logs/conversation/{conversationId} — 完整对话记录
    public function conversation(string $conversationId)
    {
        $logs = ChatLog::where('conversation_id', $conversationId)
            ->orderBy('occurred_at')
            ->get();

        return response()->json(['data' => $logs]);
    }
}
