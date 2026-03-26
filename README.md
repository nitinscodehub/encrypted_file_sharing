🔐 Encrypted File Sharing System

A secure application for encrypted file sharing and private communication. This app ensures complete data privacy using strong encryption techniques and supports both LAN-based and global messaging.

🚀 Features
📁 Secure File Encryption
Encrypt any file using AES-256 encryption
Password-based security using SHA-256 key derivation
Generates encrypted .enc files
Only receiver with correct password can decrypt
💬 LAN Chat (Offline)
Works on same WiFi network
Direct device-to-device communication
Uses TCP sockets (Port 8080)
No internet or server required
🌍 Global Chat (Online)
Works from anywhere via internet
Uses WebSocket protocol
Real-time message broadcasting
Multi-user chat support
🛡️ Security Layers
🔑 Password Protection
🔐 AES-256 Encryption (military-grade)
🧠 SHA-256 Key Derivation

➡️ Data is always encrypted before transmission
➡️ No readable data is exposed during transfer

⚙️ Tech Stack
Flutter (UI Framework)
Dart (Programming Language)
file_picker – File selection
encrypt – AES encryption
shared_preferences – Local storage
network_info_plus – IP detection
web_socket_channel – Global chat
🔄 Working Flow

File Sharing:

Select File → Set Password → Encrypt → Share → Receiver Decrypt → Original File

LAN Chat:

Enter IP → Connect → Send Message → Direct Delivery (No Server)

Global Chat:

Connect to Server → Send Message → Broadcast to All Users
⭐ Key Highlights
No server required for file sharing
LAN chat works without internet
End-to-end encrypted communication
Secure, fast, and privacy-focused
🧠 Simple Explanation
Lock File 🔐 → Share 📤 → Unlock 🔓  
Chat via IP 💬 → Chat globally 🌍  
All Secure 🚀
