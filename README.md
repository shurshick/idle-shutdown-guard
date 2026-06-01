# idle-shutdown-guard

Небольшая пользовательская служба для RPM-based Linux систем. После заданного
часа она проверяет неактивность пользователя. Если пользователь неактивен
час, появляется окно предупреждения. Выключение можно отложить на час. Если
за 5 минут его не отложить, запускается команда выключения.

## Как это работает

- Служба запускается в пользовательской systemd-сессии.
- Активность определяется через `xprintidle` на X11, если он установлен.
- Если `xprintidle` недоступен, используется `systemd-logind`.
- Диалог показывается через `zenity`, затем через `kdialog`, затем через
  критическое уведомление `notify-send` без возможности отложить.
- Выключение по умолчанию выполняется командой:

```bash
systemctl poweroff --ignore-inhibitors
```

## Настройка

Системный конфиг:

```text
/etc/idle-shutdown-guard/config.ini
```

Пользовательский конфиг, который перекрывает системный:

```text
~/.config/idle-shutdown-guard/config.ini
```

Пример:

```ini
[settings]
begin_hour = 22
idle_minutes = 60
warning_timeout_minutes = 5
defer_minutes = 60
check_interval_seconds = 60
shutdown_command = systemctl poweroff --ignore-inhibitors
```

`begin_hour = 22` означает, что проверка выполняется с 22:00 до 23:59.

## Ручная установка без RPM

```bash
sudo install -Dpm0755 src/idle-shutdown-guard /usr/bin/idle-shutdown-guard
sudo install -Dpm0644 config/config.ini /etc/idle-shutdown-guard/config.ini
sudo install -Dpm0644 systemd/idle-shutdown-guard.service /usr/lib/systemd/user/idle-shutdown-guard.service
systemctl --user daemon-reload
systemctl --user enable --now idle-shutdown-guard.service
```

Чтобы служба продолжала работать после выхода из сессии, можно включить linger:

```bash
sudo loginctl enable-linger "$USER"
```

Обычно для настольного ПК linger не нужен: служба должна работать именно пока
открыта пользовательская графическая сессия.

## Сборка RPM

Один из простых вариантов:

```bash
mkdir -p ~/rpmbuild/SOURCES
tar --transform 's,^,idle-shutdown-guard-0.1.0/,' \
  -czf ~/rpmbuild/SOURCES/idle-shutdown-guard-0.1.0.tar.gz \
  src config systemd packaging
rpmbuild -ba packaging/idle-shutdown-guard.spec
```

После установки:

```bash
systemctl --user daemon-reload
systemctl --user enable --now idle-shutdown-guard.service
```

## Проверка

Для теста можно временно поставить:

```ini
[settings]
begin_hour = 0
idle_minutes = 1
warning_timeout_minutes = 1
defer_minutes = 1
shutdown_command = notify-send "Тест выключения" "Команда выключения не запускалась"
```

После проверки верните настоящую команду выключения.
