const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

app.use(express.json());
const SECRET_KEY = 'supersecretkey';

// 로그인 및 토큰 발급
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  if (username === 'admin' && password === 'password') {
    const token = jwt.sign({ username }, SECRET_KEY);
    res.json({ token });
  } else {
    res.status(401).json({ message: 'Invalid credentials!' });
  }
});

// 보호된 경로
app.get('/protected', (req, res) => {
    const token = req.headers['authorization']?.split(' ')[1]; // Authorization 헤더에서 토큰 추출

    if (!token) {
        return res.status(401).json({ message: "Token missing" });
    }
    try {
        const decoded = jwt.verify(token, SECRET_KEY);
        return res.json({ message: "Access granted", user: decoded.user });
    } catch (err) {
        if (err instanceof jwt.TokenExpiredError) {
            return res.status(401).json({ message: "Token expired" });
        }
        return res.status(401).json({ message: "Invalid token" });
    }
});

app.listen(3003, () => {
  console.log('Notification service running on port 3003');
});
