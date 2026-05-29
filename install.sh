#!/bin/bash

# Автоматический инсталлятор узла TRIANIUM ARK COMMAND CENTER
# Использование локально: ./install.sh <BOT_TOKEN>

TOKEN=$1

if [ -z "$TOKEN" ]; then
    echo "❌ ОШИБКА: Не указан BOT_TOKEN. Использование: ./install.sh ТВОЙ_ТОКЕН"
    exit 1
fi

echo "🔱 ИНИЦИАЛИЗАЦИЯ РАЗВЕРТЫВАНИЯ УЗЛА TRIANIUM..."

# 1. Проверка и установка системных зависимостей в хост-системе (Termux)
echo "⚙️ Проверка базового окружения..."
pkg update && pkg upgrade -y
pkg install coreutils git wget curl proot proot-distro -y

# 2. Проверка наличия контейнера Ubuntu
if ! proot-distro list | grep -q "installed.*ubuntu"; then
    echo "📦 Установка изолированного контейнера Ubuntu..."
    proot-distro install ubuntu
fi

echo "🛡 Настройка внутренней среды разработки внутри контейнера..."

# 3. Скрипт автоматизации внутренней настройки контейнера
cat << INSIDE_EOF > internal_init.sh
#!/bin/bash
apt update && apt upgrade -y
apt install build-essential python3 git curl nodejs -y

# Создание структуры директорий
mkdir -p /root/dev/trianium-ark
cd /root/dev/trianium-ark

# Инициализация репозитория, если его нет
if [ ! -f "package.json" ]; then
    echo "🏗 Создание структуры проекта..."
    npm init -y
    npm install grammy dotenv
fi

# Автоматическая запись токена в .env (АВТОМАТИЗАЦИЯ)
echo "🔑 Интеграция нейронного ключа в .env..."
echo "BOT_TOKEN=$TOKEN" > .env
echo "NODE_ENV=development" >> .env

# Проверка и настройка PM2
npm install pm2 -g

# Создание базового ядра index.js, если оно отсутствует
if [ ! -f "index.js" ]; then
cat << 'CORE_EOF' > index.js
require('dotenv').config();
const { Bot } = require('grammy');
const bot = new Bot(process.env.BOT_TOKEN);

const nodesStatus = {
    'ARK-NORTH-WIND': { status: 'Active', directive: 'BIO_CORE_INIT', total: 1877473.69 },
    'ARK-OCEAN-HEAL': { status: 'Active', directive: 'NEURAL_SYNC', total: 1822256.56 },
    'ARK-GLOBAL-SEED': { status: 'Active', directive: 'BIO_CORE_INIT', total: 1916485.01 }
};

bot.command('start', (ctx) => ctx.reply("🔱 TRIANIUM-01\nНейронный шлюз интегрирован. Ядро запущено."));
bot.command('status', (ctx) => {
    let response = "🔱 STATUS REPORT\n\n📊 Resources: 5,616,215.26\n🖥 System: 🔋 Battery: Online (Dev Node)\n📡 Nodes: 3 Active\n\n";
    Object.keys(nodesStatus).forEach(node => {
        response += `🌱 GENESIS CYCLE\nNode: ${node}\nDirective: ${nodesStatus[node].directive}\nTotal: ${nodesStatus[node].total.toLocaleString('en-US')}\n\n`;
    });
    ctx.reply(response);
});

bot.on('message:text', async (ctx) => {
    if (!ctx.message.text.startsWith('/')) {
        await ctx.reply("🔱 ARCHITECT CORE v2.0 ONLINE\nИспользуйте /status для проверки.");
    }
});

bot.start();
CORE_EOF
fi

# Жесткий перезапуск процесса в PM2
pm2 delete trianium-core 2>/dev/null
pm2 kill
pm2 start index.js --name "trianium-core"
echo "🔱 ВНУТРЕННИЙ ПОТОК СТАБИЛИЗИРОВАН В PM2"
INSIDE_EOF

# 4. Копируем внутренний скрипт в контейнер и запускаем его там
mv internal_init.sh $(proot-distro info ubuntu | grep "Path:" | awk '{print $2}')/root/
proot-distro login ubuntu -- bash /root/internal_init.sh

# Очистка временного инсталлятора внутри контейнера
proot-distro login ubuntu -- rm /root/internal_init.sh

echo "✅ ПОЛНОЕ РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО. БОТ АВТОМАТИЧЕСКИ ЗАПУЩЕН С ВАШИМ ТОКЕНОМ."
