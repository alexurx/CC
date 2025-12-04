#!/bin/bash

# Скрипт для нагрузочного тестирования ALB
# Использование: ./load_test.sh <ALB_DNS> [threads] [duration]

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода справки
show_help() {
    cat << EOF
Использование: $0 <ALB_DNS> [OPTIONS]

Параметры:
    ALB_DNS         DNS имя Application Load Balancer (обязательный)
    
Опции:
    -t, --threads   Количество параллельных потоков (по умолчанию: 8)
    -d, --duration  Длительность нагрузки в секундах (по умолчанию: 60)
    -m, --method    Метод нагрузки: curl, ab, hey (по умолчанию: curl)
    -h, --help      Показать эту справку

Примеры:
    $0 my-alb-123456.eu-central-1.elb.amazonaws.com
    $0 my-alb-123456.eu-central-1.elb.amazonaws.com -t 10 -d 120
    $0 my-alb-123456.eu-central-1.elb.amazonaws.com --method ab --threads 5
    
Методы нагрузки:
    curl - Использует curl в параллельных процессах (всегда доступен)
    ab   - Apache Benchmark (требует установки)
    hey  - Modern HTTP load generator (требует установки)

EOF
    exit 0
}

# Проверка наличия инструмента
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Ошибка: $1 не установлен${NC}"
        echo "Установите с помощью:"
        case "$1" in
            ab)
                echo "  Ubuntu/Debian: sudo apt-get install apache2-utils"
                echo "  macOS: brew install httpd"
                echo "  RHEL/CentOS: sudo yum install httpd-tools"
                ;;
            hey)
                echo "  go install github.com/rakyll/hey@latest"
                echo "  или скачайте binary: https://github.com/rakyll/hey/releases"
                ;;
        esac
        return 1
    fi
    return 0
}

# Нагрузочное тестирование с curl
load_test_curl() {
    local url=$1
    local threads=$2
    local duration=$3
    
    echo -e "${GREEN}Запуск нагрузочного тестирования с curl...${NC}"
    echo "URL: $url"
    echo "Потоки: $threads"
    echo "Длительность: $duration секунд"
    echo ""
    
    local end_time=$((SECONDS + duration))
    local pids=()
    
    # Запуск потоков
    for ((i=1; i<=threads; i++)); do
        (
            local count=0
            while [ $SECONDS -lt $end_time ]; do
                curl -s -o /dev/null -w "Thread $i: %{http_code} - %{time_total}s\n" "$url"
                ((count++))
                sleep 0.5
            done
            echo "Thread $i: Завершено. Выполнено запросов: $count"
        ) &
        pids+=($!)
    done
    
    # Ожидание завершения всех потоков
    echo -e "${YELLOW}Нагрузка запущена. Ожидание завершения...${NC}"
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    echo -e "${GREEN}Нагрузочное тестирование завершено!${NC}"
}

# Нагрузочное тестирование с Apache Benchmark
load_test_ab() {
    local url=$1
    local threads=$2
    local duration=$3
    
    if ! check_tool "ab"; then
        echo -e "${YELLOW}Переключение на метод curl...${NC}"
        load_test_curl "$url" "$threads" "$duration"
        return
    fi
    
    # ab работает с количеством запросов, а не с длительностью
    # Примерная оценка: 2 запроса в секунду на поток
    local total_requests=$((threads * duration * 2))
    
    echo -e "${GREEN}Запуск нагрузочного тестирования с Apache Benchmark...${NC}"
    echo "URL: $url"
    echo "Конкурентность: $threads"
    echo "Общее количество запросов: $total_requests"
    echo ""
    
    ab -n "$total_requests" -c "$threads" -g results.tsv "$url"
    
    echo -e "${GREEN}Нагрузочное тестирование завершено!${NC}"
    echo "Результаты сохранены в results.tsv"
}

# Нагрузочное тестирование с hey
load_test_hey() {
    local url=$1
    local threads=$2
    local duration=$3
    
    if ! check_tool "hey"; then
        echo -e "${YELLOW}Переключение на метод curl...${NC}"
        load_test_curl "$url" "$threads" "$duration"
        return
    fi
    
    echo -e "${GREEN}Запуск нагрузочного тестирования с hey...${NC}"
    echo "URL: $url"
    echo "Конкурентность: $threads"
    echo "Длительность: $duration секунд"
    echo ""
    
    hey -z "${duration}s" -c "$threads" -q 1 "$url"
    
    echo -e "${GREEN}Нагрузочное тестирование завершено!${NC}"
}

# Параметры по умолчанию
ALB_DNS=""
THREADS=8
DURATION=60
METHOD="curl"

# Парсинг аргументов
if [ $# -eq 0 ]; then
    show_help
fi

ALB_DNS=$1
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -m|--method)
            METHOD="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Неизвестная опция: $1${NC}"
            show_help
            ;;
    esac
done

# Проверка обязательных параметров
if [ -z "$ALB_DNS" ]; then
    echo -e "${RED}Ошибка: DNS имя ALB не указано${NC}"
    show_help
fi

# Формирование URL
URL="http://${ALB_DNS}/load?seconds=${DURATION}"

# Информация о тесте
echo "========================================"
echo "  Нагрузочное тестирование AWS ALB"
echo "========================================"
echo "DNS: $ALB_DNS"
echo "Метод: $METHOD"
echo "Потоки: $THREADS"
echo "Длительность: $DURATION секунд"
echo "========================================"
echo ""

# Запуск соответствующего метода
case $METHOD in
    curl)
        load_test_curl "$URL" "$THREADS" "$DURATION"
        ;;
    ab)
        load_test_ab "$URL" "$THREADS" "$DURATION"
        ;;
    hey)
        load_test_hey "$URL" "$THREADS" "$DURATION"
        ;;
    *)
        echo -e "${RED}Неизвестный метод: $METHOD${NC}"
        echo "Доступные методы: curl, ab, hey"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Проверьте CloudWatch для просмотра метрик и автомасштабирования${NC}"