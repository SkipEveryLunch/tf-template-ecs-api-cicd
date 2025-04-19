FROM node:18

WORKDIR /app

# パッケージの依存関係をコピー
COPY package*.json ./
COPY prisma ./prisma/

# 依存関係をインストール
RUN npm install

# Prismaのクライアントを生成
RUN npx prisma generate

# アプリケーションのソースコードをコピー
COPY . .

# ポートを公開
EXPOSE 3000

# アプリケーションを起動
CMD ["npm", "run", "dev"] 