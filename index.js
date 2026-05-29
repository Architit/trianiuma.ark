require('dotenv').config();
const { Bot } = require('grammy');

if (!process.env.BOT_TOKEN) {
    console.error("❌ КРИТИЧЕСКАЯ ОШИБКА: Токен бота не найден в .env");
    process.exit(1);
}

const bot = new Bot(process.env.BOT_TOKEN);

// Имитация базы данных метаболизма узлов
const nodesStatus = {
    'ARK-NORTH-WIND': { status: 'Active', directive: 'BIO_CORE_INIT', total: 1877473.69 },
    'ARK-OCEAN-HEAL': { status: 'Active', directive: 'NEURAL_SYNC', total: 1822256.56 },
    'ARK-GLOBAL-SEED': { status: 'Active', directive: 'BIO_CORE_INIT', total: 1916485.01 }
};

// Команда /start
bot.command('start', (ctx) => {
    ctx.reply("🔱 TRIANIUM-01\nНейронный шлюз успешно интегрирован. Ядро запущено. Ожидание потока...");
});

// Команда /status
bot.command('status', (ctx) => {
    let response = "🔱 STATUS REPORT\n\n";
    let totalResources = 0;
    
    Object.keys(nodesStatus).forEach(node => {
        totalResources += nodesStatus[node].total;
    });

    response += `📊 Resources: ${totalResources.toLocaleString('en-US')}\n`;
    response += `🖥 System: 🔋 Battery: Online (Dev Node)\n`;
    response += `📡 Nodes: ${Object.keys(nodesStatus).length} Active\n\n`;
    
    Object.keys(nodesStatus).forEach(node => {
        response += `🌱 GENESIS CYCLE\nNode: ${node}\nDirective: ${nodesStatus[node].directive}\nTotal: ${nodesStatus[node].total.toLocaleString('en-US')}\n\n`;
    });

    ctx.reply(response);
});

// Хэндлер на любые текстовые сообщения (для симуляции потока)
bot.on('message:text', async (ctx) => {
    if (ctx.message.text.startsWith('/')) return;
    await ctx.reply("🔱 ARCHITECT CORE v2.0 ONLINE\nКомандный центр готов. Используйте /status для проверки.");
});

bot.catch((err) => {
    console.error(`[🔥 ERROR] Ошибка в ядре бота:`, err);
});

console.log("🔱 TRIANIUM COMMAND CENTER ПОДКЛЮЧЕН К СЕТИ...");
bot.start();
