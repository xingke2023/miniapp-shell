<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class WeworkCallbackController extends Controller
{
    private string $token = 'fB9qhVa431zqBDUSZJDlG';
    private string $encodingAesKey = 'qMu5WGOEXpGm5ZtLX2NPJfrJ2gu8zw11E81Q7wHcX9J';
    private string $corpId = '';

    /**
     * GET 验证回调URL
     */
    public function verify(Request $request): Response
    {
        $msgSignature = $request->query('msg_signature', '');
        $timestamp = $request->query('timestamp', '');
        $nonce = $request->query('nonce', '');
        $echostr = $request->query('echostr', '');

        // 验证签名
        if (! $this->checkSignature($msgSignature, $timestamp, $nonce, $echostr)) {
            return response('Invalid signature', 403);
        }

        // 解密 echostr
        $decrypted = $this->decrypt($echostr);
        if ($decrypted === false) {
            return response('Decrypt failed', 403);
        }

        return response($decrypted, 200)->header('Content-Type', 'text/plain');
    }

    /**
     * POST 接收业务回调消息
     */
    public function receive(Request $request): Response
    {
        $msgSignature = $request->query('msg_signature', '');
        $timestamp = $request->query('timestamp', '');
        $nonce = $request->query('nonce', '');

        $xmlBody = $request->getContent();
        $xml = simplexml_load_string($xmlBody, 'SimpleXMLElement', LIBXML_NOCDATA);
        if (! $xml) {
            return response('Invalid XML', 400);
        }

        $encrypt = (string) $xml->Encrypt;

        // 验证签名
        if (! $this->checkSignature($msgSignature, $timestamp, $nonce, $encrypt)) {
            return response('Invalid signature', 403);
        }

        // 解密消息
        $decrypted = $this->decrypt($encrypt);
        if ($decrypted === false) {
            return response('Decrypt failed', 403);
        }

        // 解析明文消息
        $msgXml = simplexml_load_string($decrypted, 'SimpleXMLElement', LIBXML_NOCDATA);

        // TODO: 根据业务需要处理 $msgXml 消息
        // $msgType = (string) $msgXml->MsgType;
        // $event   = (string) $msgXml->Event;

        return response('success', 200)->header('Content-Type', 'text/plain');
    }

    /**
     * 验证消息签名
     * 签名规则: sort([token, timestamp, nonce, encrypt]) => sha1
     */
    private function checkSignature(string $msgSignature, string $timestamp, string $nonce, string $encrypt): bool
    {
        $arr = [$this->token, $timestamp, $nonce, $encrypt];
        sort($arr, SORT_STRING);
        $signature = sha1(implode('', $arr));

        return hash_equals($signature, $msgSignature);
    }

    /**
     * 解密企业微信 AES 加密消息
     * AES-256-CBC, key = base64_decode(encodingAesKey + '='), iv = key 前16字节
     */
    private function decrypt(string $encrypt): string|false
    {
        $aesKey = base64_decode($this->encodingAesKey.'=');
        $iv = substr($aesKey, 0, 16);

        $decrypted = openssl_decrypt(
            base64_decode($encrypt),
            'AES-256-CBC',
            $aesKey,
            OPENSSL_RAW_DATA | OPENSSL_ZERO_PADDING,
            $iv
        );

        if ($decrypted === false) {
            return false;
        }

        // 去除 PKCS7 padding
        $decrypted = $this->pkcs7Unpad($decrypted);

        // 数据格式: 16字节random + 4字节消息长度(网络字节序) + 消息体 + receiveid
        if (strlen($decrypted) < 20) {
            return false;
        }

        $msgLen = unpack('N', substr($decrypted, 16, 4))[1];
        $msg = substr($decrypted, 20, $msgLen);

        return $msg;
    }

    private function pkcs7Unpad(string $data): string
    {
        $pad = ord(substr($data, -1));
        if ($pad < 1 || $pad > 32) {
            return $data;
        }

        return substr($data, 0, strlen($data) - $pad);
    }
}
