const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

const app = express();
const port = 3000;
const prisma = new PrismaClient();

// ミドルウェアの設定
app.use(cors());
app.use(express.json());

// ヘルスチェックエンドポイント
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// 全てのTodoを取得
app.get('/todos', async (req, res) => {
  try {
    const todos = await prisma.todo.findMany();
    res.json(todos);
  } catch (error) {
    res.status(500).json({ error: 'Todoの取得に失敗しました' });
  }
});

// 新しいTodoを作成
app.post('/todos', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: 'nameは必須です' });
    }

    const newTodo = await prisma.todo.create({
      data: {
        name,
      },
    });
    res.status(201).json(newTodo);
  } catch (error) {
    res.status(500).json({ error: 'Todoの作成に失敗しました' });
  }
});

// Todoを削除
app.delete('/todos/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    await prisma.todo.delete({
      where: {
        id,
      },
    });
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Todoの削除に失敗しました' });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
}); 