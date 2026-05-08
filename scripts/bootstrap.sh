#!/bin/bash
echo "[BOOTSTRAP] Запуск мобильного узла TRIANIUMA..."
echo "[BOOTSTRAP] Проверка связи с Termux:API..."
if command -v termux-battery-status &> /dev/null; then
    echo "[BOOTSTRAP] API Bridge: ONLINE"
else
    echo "[BOOTSTRAP] API Bridge: LOCAL_ONLY"
fi
