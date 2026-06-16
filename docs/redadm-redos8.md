# Распространение через RedADM на RedOS 8

Да, пакет можно распространять через RedADM на клиенты с RedOS 8 как обычный
RPM-пакет.

## Рекомендуемый сценарий

1. Собрать релизный RPM:

```bash
bash scripts/build-packages.sh 0.2.3
```

2. Взять пакет из `dist/`, например:

```text
idle-shutdown-guard-0.2.3-1.noarch.rpm
```

3. Загрузить RPM в RedADM и назначить установку на нужную группу клиентов.

4. После установки программа стартует в графической сессии пользователя через:

```text
/etc/xdg/autostart/idle-shutdown-guard.desktop
```

Поэтому отдельно включать `systemctl --user enable idle-shutdown-guard.service`
на каждой машине не требуется.

## Что проверить на RedOS 8

- В репозиториях клиентов доступны зависимости `python3`, `python3-gobject`,
  `gtk3`, `systemd`, `zenity`.
- Для более точного определения простоя на X11 желательно установить
  `xprintidle`.
- Пользовательская графическая сессия должна разрешать локальному активному
  пользователю выполнять `systemctl poweroff --ignore-inhibitors`.
- Если в организации выключение через polkit ограничено, понадобится отдельное
  правило polkit или замена `shutdown_command` в конфиге.

## Настройки

Глобальный конфиг ставится в:

```text
/etc/idle-shutdown-guard/config.ini
```

Пользователь может переопределить настройки через форму в трее. Эти настройки
будут сохранены в:

```text
~/.config/idle-shutdown-guard/config.ini
```

Для централизованной политики лучше распространять именно системный
`/etc/idle-shutdown-guard/config.ini`.
